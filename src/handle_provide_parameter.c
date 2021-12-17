#include "opensea_plugin.h"

// Copies the whole parameter (32 bytes long) from `src` to `dst`.
// Useful for numbers, data...
static void copy_parameter(uint8_t *dst, size_t dst_len, uint8_t *src)
{
    // Take the minimum between dst_len and parameter_length to make sure we don't overwrite memory.
    size_t len = MIN(dst_len, PARAMETER_LENGTH);
    memcpy(dst, src, len);
}

// Copies a 20 byte address (located in a 32 bytes parameter) `from `src` to `dst`.
// Useful for token addresses, user addresses...
static void copy_address(uint8_t *dst, size_t dst_len, uint8_t *src)
{
    // An address is 20 bytes long: so we need to make sure we skip the first 12 bytes!
    size_t offset = PARAMETER_LENGTH - ADDRESS_LENGTH;
    size_t len = MIN(dst_len, ADDRESS_LENGTH);
    memcpy(dst, &src[offset], len);
}

static void handle_transfer_from_method(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH)
        PRINTF("in tranferFrom 'from' p1\n");
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 2)
    {
        PRINTF("in transferFrom 'from' p2, 'to' p1, ORDER_SIDE: %d\n", context->booleans & ORDER_SIDE);
        // If it's a buy now, check if 'to' part1 is sender.
        if (!(context->booleans & ORDER_SIDE))
            memcpy(context->beneficiary, &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH + SELECTOR_SIZE], ADDRESS_LENGTH - SELECTOR_SIZE);
    }
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 3)
    {
        PRINTF("in transferFrom 'to' p2, 'tokenID' p1\n");
        // If it's a 'buy now' checks if 'to' part2 is sender.
        if (!(context->booleans & ORDER_SIDE))
            memcpy(&context->beneficiary[ADDRESS_LENGTH - SELECTOR_SIZE], msg->parameter, SELECTOR_SIZE);
        memcpy(context->token_id, msg->parameter + SELECTOR_SIZE, PARAMETER_LENGTH - SELECTOR_SIZE);
    }
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 4)
    {
        PRINTF("in tranferFrom 'tokenID' part 2\n");
        memcpy(context->token_id + PARAMETER_LENGTH - SELECTOR_SIZE, msg->parameter, SELECTOR_SIZE);
        PRINTF("copied 'tokenID':\n");
        print_bytes(context->token_id, PARAMETER_LENGTH);
    }
}

static void handle_atomicize(ethPluginProvideParameter_t *msg, opensea_parameters_t *context, uint16_t offset)
{
    // skip all checks if we already found multiple addresses.
    if (context->booleans & MULTIPLE_NFT_ADDRESSES || context->booleans & COULD_NOT_PARSE)
        return;

    // Here we are on atomicize's calldata length.
    if (msg->parameterOffset == offset + PARAMETER_LENGTH * 6)
    {
        // Copy bundle_size (uint16)
        context->bundle_size = U2BE(msg->parameter, 2);
        PRINTF("bundle size: %d\n", context->bundle_size);
        // Copy the first part of nft_address.
        memcpy(context->nft_contract_address, msg->parameter + SELECTOR_SIZE + (PARAMETER_LENGTH - ADDRESS_LENGTH), ADDRESS_LENGTH - SELECTOR_SIZE);
    }
    // Here we are on atomicize's calldata's NFTs addresses array.
    else if (msg->parameterOffset > offset + PARAMETER_LENGTH * 6 && msg->parameterOffset <= offset + PARAMETER_LENGTH * (6 + context->bundle_size))
    {
        // Copy end of nft_address the first time.
        if (!(context->booleans & NFT_ADDRESS_COPIED))
        {
            memcpy(&context->nft_contract_address[ADDRESS_LENGTH - SELECTOR_SIZE], msg->parameter, SELECTOR_SIZE);
            // Rise NFT_ADDRESS_COPIED.
            context->booleans |= NFT_ADDRESS_COPIED;
        }
        // Once nft_address is copied, memcmp to check if there is multiple addresses.
        // Memcmp the first part of the address.
        if (msg->parameterOffset <= offset + PARAMETER_LENGTH * (6 + context->bundle_size - 1))
        {
            if (memcmp(context->nft_contract_address, msg->parameter + SELECTOR_SIZE + (PARAMETER_LENGTH - ADDRESS_LENGTH), ADDRESS_LENGTH - SELECTOR_SIZE))
                context->booleans |= MULTIPLE_NFT_ADDRESSES;
        }
        // Memcmp the last part of the address.
        if (memcmp(&context->nft_contract_address[ADDRESS_LENGTH - SELECTOR_SIZE], msg->parameter, SELECTOR_SIZE))
            context->booleans |= MULTIPLE_NFT_ADDRESSES;
    }
    else if (msg->parameterOffset == offset + PARAMETER_LENGTH * (7 + context->bundle_size))
        PRINTF("On atomicize values[] length\n");
    // On atomicize calldata_length[] length
    else if (msg->parameterOffset == offset + PARAMETER_LENGTH * (8 + context->bundle_size * 2))
    {
        PRINTF("\033[0;33mOn atomicize calldata_length[] length\033[0m\n");
        if (U2BE(msg->parameter, 2) != context->bundle_size)
            context->booleans |= COULD_NOT_PARSE;
    }
    // On atomicize calldata_length[] values
    else if (msg->parameterOffset > offset + PARAMETER_LENGTH * (8 + context->bundle_size * 2) && msg->parameterOffset < offset + PARAMETER_LENGTH * (9 + context->bundle_size * 3))
    {
        PRINTF("\033[0;33mOn atomicize calldata_length[] values\033[0m\n");
        // Copy first one.
        if (context->atomicize_lengths == 0)
            context->atomicize_lengths = U2BE(msg->parameter, 2);
        // memcmp others.
        else if (context->atomicize_lengths != U2BE(msg->parameter, 2))
            context->booleans |= COULD_NOT_PARSE;
    }
    // On atomicize on calldata length.
    else if (msg->parameterOffset == offset + PARAMETER_LENGTH * (9 + context->bundle_size * 3))
    {
        PRINTF("On atomicize CALLDATA LENGTH = %hu\n", msg->parameter); //random selector_ size
        context->atomicize_length = U2BE(msg->parameter, 2);
        memcpy(context->atomicize_selector, &msg->parameter[SELECTOR_SIZE], SELECTOR_SIZE);

        if (context->atomicize_length != context->bundle_size * context->atomicize_lengths)
        {
            PRINTF("atomicize lengths != total length\n");
            context->booleans |= COULD_NOT_PARSE;
        }
        // Handle first loop.
        context->atomicize_length -= PARAMETER_LENGTH;
    }
    // Loop through atomicize calldata.
    else if (context->atomicize_length > 0)
    {
        if (context->atomicize_length > PARAMETER_LENGTH)
        {
            // subcalldata_remaining_length is sub-calldata remaining length
            uint16_t subcalldata_remaining_length = (context->atomicize_length - context->current_atomicize_offset) % context->atomicize_lengths;
            PRINTF("\033[0;31msubcalldata_remaining_length: %d \033[0m\n", subcalldata_remaining_length);
            // handle sub-calldata offset shifting at the end of each sub-calldatas.
            if (subcalldata_remaining_length == 0)
                context->current_atomicize_offset += SELECTOR_SIZE;
            if (subcalldata_remaining_length == 0 && context->current_atomicize_offset != PARAMETER_LENGTH)
            {
                // Cmp methodId.
                if (memcmp(context->atomicize_selector, &msg->parameter[context->current_atomicize_offset], SELECTOR_SIZE))
                    context->booleans |= COULD_NOT_PARSE;
            }
            // wrap special case (methodId at the end of parameter)
            else if (subcalldata_remaining_length == context->atomicize_lengths - SELECTOR_SIZE)
            {
                if (memcmp(context->atomicize_selector, &msg->parameter[context->current_atomicize_offset], SELECTOR_SIZE))
                    context->booleans |= COULD_NOT_PARSE;
            }
            else if (context->on_param == ON_CALLDATA && context->current_atomicize_offset < ADDRESS_LENGTH - SELECTOR_SIZE)
            {
                // THE ADDRESS IS SPLIT ONLY HERE
                if (subcalldata_remaining_length == context->atomicize_lengths - PARAMETER_LENGTH - SELECTOR_SIZE)
                {
                    uint8_t offset = (context->current_atomicize_offset + 16) % PARAMETER_LENGTH; //useless %PARM_L ?
                    // MEMCMP first part
                    if (memcmp(context->beneficiary, &msg->parameter[offset], PARAMETER_LENGTH - offset))
                        context->screen_array |= WARNING_BENEFICIARY_UI;
                }
                else if (context->on_param == ON_CALLDATA && subcalldata_remaining_length == context->atomicize_lengths - (PARAMETER_LENGTH * 2) - SELECTOR_SIZE)
                {
                    uint8_t offset = (context->current_atomicize_offset + 16) % PARAMETER_LENGTH; //useless %PARM_L ?
                    // MEMCMP second part
                    if (memcmp(&context->beneficiary[PARAMETER_LENGTH - offset], msg->parameter, PARAMETER_LENGTH - offset))
                        context->screen_array |= WARNING_BENEFICIARY_UI;
                }
            }
            else if (context->on_param == ON_CALLDATA && context->current_atomicize_offset >= ADDRESS_LENGTH - SELECTOR_SIZE)
            {
                // Address is not split here.
                if (subcalldata_remaining_length == context->atomicize_lengths - (PARAMETER_LENGTH * 2) - SELECTOR_SIZE)
                {
                    uint8_t offset = (context->current_atomicize_offset + 16) % PARAMETER_LENGTH;
                    //MEMCMP, it will already be copied
                    if (memcmp(context->beneficiary, &msg->parameter[offset], ADDRESS_LENGTH))
                        context->screen_array |= WARNING_BENEFICIARY_UI;
                }
            }
            if (context->current_atomicize_offset == PARAMETER_LENGTH)
                context->current_atomicize_offset = 0;
            context->atomicize_length -= PARAMETER_LENGTH;
        }
        else
        {
            PRINTF("atomicize_length reset\n");
            context->atomicize_length = 0;
        }
    }
}

static void handle_calldata(ethPluginProvideParameter_t *msg, opensea_parameters_t *context, uint32_t offset)
{
    PRINTF("IN CALLDATA offset:%d\n", offset);
    PRINTF("IN CALLDATA target:%d =? current:%d\n", offset + context->next_parameter_length, msg->parameterOffset);
    // Find calldata Method ID.
    if (offset != 0 && msg->parameterOffset == offset + PARAMETER_LENGTH)
    {
        PRINTF("CALLDATA METHOD: %x%x%x%x\n", msg->parameter[0], msg->parameter[1], msg->parameter[2], msg->parameter[3]);
        PRINTF("on param value: %d\n", context->on_param);
        uint8_t i;
        for (i = 0; i < NUM_NFT_SELECTORS; i++)
        {
            context->calldata_method = i;
            if (memcmp((uint8_t *)PIC(ERC721_SELECTORS[i]), msg->parameter, SELECTOR_SIZE) == 0)
            {
                PRINTF("CALLDATA METHOD FOUND: %d!\n", context->calldata_method);
                if (context->calldata_method == ATOMICIZE)
                    context->current_atomicize_offset = SELECTOR_SIZE;
                break;
            }
        }
    }
    if (context->calldata_method == ATOMICIZE)
        handle_atomicize(msg, context, offset);
    else if (context->calldata_method != METHOD_NOT_FOUND)
        handle_transfer_from_method(msg, context);
    else
        PRINTF("warning: unknown calldata method id\n");
    // End of calldata
    PRINTF("offset: %d, context->next_parameter_length: %d, msg->parameterOffset: %d\n", offset, context->next_parameter_length, msg->parameterOffset);
    if (offset + context->next_parameter_length + PARAMETER_LENGTH - SELECTOR_SIZE == msg->parameterOffset)
    {
        PRINTF("END OF CALLDATA\n");
        context->on_param = ON_NONE;
        // Reset in order to parse both sides
        context->atomicize_lengths = 0;
        context->atomicize_length = 0;
    }
}

static void handle_cancel_order(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    // Here we are on a calldata
    if (context->on_param == ON_CALLDATA)
        handle_calldata(msg, context, context->calldata_offset);
    // Is on calldata_length parameter
    if (context->calldata_offset != 0 && msg->parameterOffset == context->calldata_offset)
    {
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in \033[0;32mCALLDATA_LENGTH\033[0m PARAM\n");
        context->next_parameter_length = U2BE(msg->parameter, PARAMETER_LENGTH - 2);
        PRINTF("context->next_parameter_length = %d\n", context->next_parameter_length);
        context->on_param = ON_CALLDATA;
        PRINTF("FLAG3\n");
    }

    switch ((cancel_order_parameter)context->next_param)
    {
    case EXCHANGE_ADDRESS:
    case MAKER_ADDRESS:
    case TAKER_ADDRESS:
    case FEE_RECIPIENT_ADDRESS:
        break;
    case TARGET_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in TARGET_ADDRESS PARAM\n");
        copy_address(context->nft_contract_address,
                     sizeof(context->nft_contract_address),
                     msg->parameter);
        break;
    case STATIC_TARGET_ADDRESS:
        break;
    case PAYMENT_TOKEN_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in PAYMENT_TOKEN_ADDRESS PARAM\n");
        copy_address(context->payment_token_address,
                     sizeof(context->payment_token_address),
                     msg->parameter);
        break;
    case MAKER_RELAYER_FEE:
    case TAKER_RELAYER_FEE:
    case MAKER_PROTOCOL_FEE:
    case TAKER_PROTOCOL_FEE:
        break;
    case BASE_PRICE:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in BASE_PRICE PARAM\n");
        copy_parameter(context->payment_token_amount,
                       sizeof(context->payment_token_amount),
                       msg->parameter);
        break;
    case EXTRA:
    case LISTING_TIME:
    case EXPIRATION_TIME:
    case SALT:
    case FEE_METHOD:
        break;
    case SIDE:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in SIDE PARAM\n");
        // This value is either 1 or 0.
        if (msg->parameter[PARAMETER_LENGTH - 1])
            context->booleans |= ORDER_SIDE;
        break;
    case SALE_KIND:
    case HOW_TO_CALL:
        break;
    case CALLDATA_OFFSET:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in CALLDATA_OFFSET PARAM\n");
        PRINTF("\033[0;34m OFFSETT: %d\n", U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE);
        PRINTF("\033[0m");
        context->calldata_offset = U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE;
        break;
    case REPLACEMENT_PATTERN_OFFSET:
    case STATIC_EXTRADATA_OFFSET:
        break;
    default:
        break;
    }
    context->next_param++;
}

static void handle_atomic_match(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    // Here we are on a calldata
    if (context->on_param)
    {
        if (context->on_param == ON_CALLDATA)
            handle_calldata(msg, context, context->calldata_offset);
        else if (context->on_param == ON_CALLDATA_SELL)
            handle_calldata(msg, context, context->calldata_sell_offset);
        return;
    }
    // is on first calldata length
    if (context->calldata_offset != 0 && msg->parameterOffset == context->calldata_offset)
    {
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in \033[0;32mCALLDATA_LENGTH\033[0m PARAM\n");
        context->next_parameter_length = U2BE(msg->parameter, PARAMETER_LENGTH - 2);
        PRINTF("context->next_parameter_length = %d\n", context->next_parameter_length);
        context->on_param = ON_CALLDATA;
    }
    // is on second calldata length
    else if (context->calldata_sell_offset != 0 && msg->parameterOffset == context->calldata_sell_offset)
    {
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in \033[0;32mCALLDATA_SELL_LENGTH\033[0m PARAM\n");
        context->next_parameter_length = U2BE(msg->parameter, PARAMETER_LENGTH - 2);
        PRINTF("context->next_parameter_length = %d\n", context->next_parameter_length);
        context->on_param = ON_CALLDATA_SELL;
    }

    switch ((atomic_match_parameter)context->next_param)
    {
    case BUY_EXCHANGE_ADDRESS:
        break;
    case BUY_MAKER_ADDRESS:
        copy_address(context->beneficiary, sizeof(context->beneficiary), msg->parameter);
        break;
    case BUY_TAKER_ADDRESS:
        // use buy_taker_address to determine order_side
        if (!(memcmp(msg->parameter, NULL_ADDRESS, ADDRESS_LENGTH)))
            context->booleans |= ORDER_SIDE;
        break;
    case BUY_FEE_RECIPIENT_ADDRESS:
        break;
    case BUY_TARGET_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in TARGET_ADDRESS PARAM\n");
        // set context->nft_contract_address
        copy_address(context->nft_contract_address,
                     sizeof(context->nft_contract_address),
                     msg->parameter);
        break;
    case BUY_STATIC_TARGET_ADDRESS:
        break;
    case BUY_PAYMENT_TOKEN_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in PAYMENT_TOKEN_ADDRESS PARAM\n");
        // set context->payment_token_address
        copy_address(context->payment_token_address,
                     sizeof(context->payment_token_address),
                     msg->parameter);
        break;
    case BUY_MAKER_RELAYER_FEE:
    case BUY_TAKER_RELAYER_FEE:
    case BUY_MAKER_PROTOCOL_FEE:
    case BUY_TAKER_PROTOCOL_FEE:
        break;
    case BUY_BASE_PRICE:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in BASE_PRICE PARAM\n");
        // set context->payment_token_amount
        copy_parameter(context->payment_token_amount,
                       sizeof(context->payment_token_amount),
                       msg->parameter);
        break;
    case BUY_EXTRA:
    case BUY_LISTING_TIME:
    case BUY_EXPIRATION_TIME:
    case BUY_SALT:
    case BUY_FEE_METHOD:
        break;
    case BUY_SIDE:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in BUY_SIDE PARAM\n");
        break;
    case BUY_SALE_KIND:
    case BUY_HOW_TO_CALL:
    case SELL_EXCHANGE_ADDRESS:
    case SELL_MAKER_ADDRESS:
    case SELL_TAKER_ADDRESS:
    case SELL_FEE_RECIPIENT_ADDRESS:
    case SELL_TARGET_ADDRESS:
        // already catch in BUY order
    case SELL_STATIC_TARGET_ADDRESS:
    case SELL_PAYMENT_TOKEN_ADDRESS:
        // already catch in BUY order
    case SELL_MAKER_RELAYER_FEE:
    case SELL_TAKER_RELAYER_FEE:
    case SELL_MAKER_PROTOCOL_FEE:
    case SELL_TAKER_PROTOCOL_FEE:
    case SELL_BASE_PRICE:
        // already catch in BUY order
    case SELL_EXTRA:
    case SELL_LISTING_TIME:
    case SELL_EXPIRATION_TIME:
    case SELL_SALT:
    case SELL_FEE_METHOD:
        break;
    case SELL_SIDE:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in SELL_SIDE PARAM\n");
        break;
    case SELL_SALE_KIND:
    case SELL_HOW_TO_CALL:
        break;
    case BUY_CALLDATA_OFFSET:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in CALLDATA_OFFSET PARAM\n");
        PRINTF("\033[0;34m OFFSETT: %d\n", U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE);
        PRINTF("\033[0m");
        context->calldata_offset = U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE;
        break;
    case SELL_CALLDATA_OFFSET:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in CALLDATA_OFFSET PARAM\n");
        PRINTF("\033[0;34m OFFSETT: %d\n", U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE);
        PRINTF("\033[0m");
        context->calldata_sell_offset = U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE;
        break;
    case BUY_REPLACEMENT_PATTERN_OFFSET:
    case SELL_REPLACEMENT_PATTERN_OFFSET:
    case BUY_STATIC_EXTRADATA_OFFSET:
    case SELL_STATIC_EXTRADATA_OFFSET:
        break;
    default:
        break;
    }
    context->next_param++;
}

void handle_provide_parameter(void *parameters)
{
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;
    PRINTF("PROVIDE PARAMETER, selector: %d\n", context->selectorIndex);

    msg->result = ETH_PLUGIN_RESULT_OK;
    //Print current parameter
    PRINTF("\033[0;31mPROVIDE PARAMETER - current parameter:\n");
    print_bytes(msg->parameter, PARAMETER_LENGTH);
    PRINTF("\033[0m\n");

    switch (context->selectorIndex)
    {
    case REGISTER_PROXY:
        break;
    case CANCEL_ORDER_:
        handle_cancel_order(msg, context);
        break;
    case ATOMIC_MATCH_:
        handle_atomic_match(msg, context);
        break;
    default:
        PRINTF("Selector Index %d not supported\n", context->selectorIndex);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
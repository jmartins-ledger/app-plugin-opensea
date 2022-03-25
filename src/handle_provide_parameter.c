#include "opensea_plugin.h"

static void handle_match_erc721(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH)
        return;
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 2)
    {
        // If it's a buy now, check if 'to' part1 is sender.
        if (!(context->booleans & ORDER_SIDE))
            memcpy(context->beneficiary, &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH + SELECTOR_SIZE], ADDRESS_LENGTH - SELECTOR_SIZE);
    }
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 3)
    {
        // If it's a 'buy now' checks if 'to' part2 is sender.
        if (!(context->booleans & ORDER_SIDE))
        {
            memcpy(&context->beneficiary[ADDRESS_LENGTH - SELECTOR_SIZE], msg->parameter, SELECTOR_SIZE);
        }
        memcpy(context->nft_contract_address, &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH + SELECTOR_SIZE], ADDRESS_LENGTH - SELECTOR_SIZE);
    }
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 4)
    {
        memcpy(context->token_id, msg->parameter + SELECTOR_SIZE, PARAMETER_LENGTH - SELECTOR_SIZE);
        memcpy(&context->nft_contract_address[ADDRESS_LENGTH - SELECTOR_SIZE], msg->parameter, SELECTOR_SIZE);
    }
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 5)
    {
        memcpy(context->token_id + PARAMETER_LENGTH - SELECTOR_SIZE, msg->parameter, SELECTOR_SIZE);
    }
}

static void handle_transfer_from_method(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH)
        return;
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 2)
    {
        // If it's a buy now, check if 'to' part1 is sender.
        if (!(context->booleans & ORDER_SIDE))
            memcpy(context->beneficiary, &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH + SELECTOR_SIZE], ADDRESS_LENGTH - SELECTOR_SIZE);
    }
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 3)
    {
        // If it's a 'buy now' checks if 'to' part2 is sender.
        if (!(context->booleans & ORDER_SIDE))
            memcpy(&context->beneficiary[ADDRESS_LENGTH - SELECTOR_SIZE], msg->parameter, SELECTOR_SIZE);
        memcpy(context->token_id, msg->parameter + SELECTOR_SIZE, PARAMETER_LENGTH - SELECTOR_SIZE);
    }
    else if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 4)
    {
        memcpy(context->token_id + PARAMETER_LENGTH - SELECTOR_SIZE, msg->parameter, SELECTOR_SIZE);
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
    // On atomicize calldata_length[] length
    else if (msg->parameterOffset == offset + PARAMETER_LENGTH * (8 + context->bundle_size * 2))
    {
        if (U2BE(msg->parameter, 2) != context->bundle_size)
        {
            context->booleans |= COULD_NOT_PARSE;
        }
    }
    // On atomicize calldata_length[] values
    else if (msg->parameterOffset > offset + PARAMETER_LENGTH * (8 + context->bundle_size * 2) && msg->parameterOffset < offset + PARAMETER_LENGTH * (9 + context->bundle_size * 3))
    {
        // Copy first one.
        if (context->atomicize_lengths == 0)
            context->atomicize_lengths = U2BE(msg->parameter, 2);
        // memcmp others.
        else if (context->atomicize_lengths != U2BE(msg->parameter, 2))
        {
            context->booleans |= COULD_NOT_PARSE;
        }
    }
    // On atomicize on calldata length.
    else if (msg->parameterOffset == offset + PARAMETER_LENGTH * (9 + context->bundle_size * 3))
    {
        context->atomicize_length = U2BE(msg->parameter, 2);
        memcpy(context->atomicize_selector, &msg->parameter[SELECTOR_SIZE], SELECTOR_SIZE);

        if (context->atomicize_length != context->bundle_size * context->atomicize_lengths)
        {
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
            // handle sub-calldata offset shifting at the end of each sub-calldatas.
            if (subcalldata_remaining_length == 0)
                context->current_atomicize_offset += SELECTOR_SIZE;
            if (subcalldata_remaining_length == 0 && context->current_atomicize_offset != PARAMETER_LENGTH)
            {
                // Cmp methodId.
                if (memcmp(context->atomicize_selector, &msg->parameter[context->current_atomicize_offset], SELECTOR_SIZE))
                {
                    context->booleans |= COULD_NOT_PARSE;
                }
            }
            // wrap special case (methodId at the end of parameter)
            else if (subcalldata_remaining_length == context->atomicize_lengths - SELECTOR_SIZE)
            {
                if (memcmp(context->atomicize_selector, &msg->parameter[context->current_atomicize_offset], SELECTOR_SIZE))
                {
                    context->booleans |= COULD_NOT_PARSE;
                }
            }
            else if (context->on_param == ON_CALLDATA && context->current_atomicize_offset < ADDRESS_LENGTH - SELECTOR_SIZE)
            {
                // THE ADDRESS IS SPLIT ONLY HERE
                if (subcalldata_remaining_length == context->atomicize_lengths - PARAMETER_LENGTH - SELECTOR_SIZE)
                {
                    uint8_t offset = (context->current_atomicize_offset + 16) % PARAMETER_LENGTH; // useless %PARM_L ?
                    // MEMCMP first part
                    if (memcmp(context->beneficiary, &msg->parameter[offset], PARAMETER_LENGTH - offset) && context->selectorIndex == ATOMIC_MATCH_)
                    {
                        context->screen_array |= WARNING_BENEFICIARY_UI;
                    }
                }
                else if (context->on_param == ON_CALLDATA && subcalldata_remaining_length == context->atomicize_lengths - (PARAMETER_LENGTH * 2) - SELECTOR_SIZE)
                {
                    uint8_t offset = (context->current_atomicize_offset + 16) % PARAMETER_LENGTH; // useless %PARM_L ?
                    uint8_t remaining_address_length = ADDRESS_LENGTH - (PARAMETER_LENGTH - offset);
                    // MEMCMP second part
                    if (memcmp(&context->beneficiary[PARAMETER_LENGTH - offset], msg->parameter, remaining_address_length) && context->selectorIndex == ATOMIC_MATCH_)
                    {
                        context->screen_array |= WARNING_BENEFICIARY_UI;
                    }
                }
            }
            else if (context->on_param == ON_CALLDATA && context->current_atomicize_offset >= ADDRESS_LENGTH - SELECTOR_SIZE)
            {
                // Address is not split here.
                if (subcalldata_remaining_length == context->atomicize_lengths - (PARAMETER_LENGTH * 2) - SELECTOR_SIZE)
                {
                    uint8_t offset = (context->current_atomicize_offset + 16) % PARAMETER_LENGTH;
                    // MEMCMP, it will already be copied
                    if (memcmp(context->beneficiary, &msg->parameter[offset], ADDRESS_LENGTH) && context->selectorIndex == ATOMIC_MATCH_)
                    {
                        context->screen_array |= WARNING_BENEFICIARY_UI;
                    }
                }
            }
            if (context->current_atomicize_offset == PARAMETER_LENGTH)
                context->current_atomicize_offset = 0;
            context->atomicize_length -= PARAMETER_LENGTH;
        }
        else
        {
            context->atomicize_length = 0;
        }
    }
}

static void handle_calldata(ethPluginProvideParameter_t *msg, opensea_parameters_t *context, uint32_t offset)
{
    // Find calldata Method ID.
    if (offset != 0 && msg->parameterOffset == offset + PARAMETER_LENGTH)
    {
        uint8_t i;
        for (i = 0; i < NUM_NFT_SELECTORS; i++)
        {
            context->calldata_method = i;
            if (memcmp((uint8_t *)PIC(ERC721_SELECTORS[i]), msg->parameter, SELECTOR_SIZE) == 0)
            {
                if (context->calldata_method == ATOMICIZE)
                    context->current_atomicize_offset = SELECTOR_SIZE;
                break;
            }
        }
    }
    if (context->calldata_method == ATOMICIZE)
        handle_atomicize(msg, context, offset);
    else if ((context->calldata_method == MATCH_ERC721_USING_CRITERIA) || (context->calldata_method == MATCH_ERC1155_USING_CRITERIA) || (context->calldata_method == MATCH_ERC721_WITH_SAFE_TRANSFER_USING_CRITERIA))
        handle_match_erc721(msg, context);
    else if (context->calldata_method != METHOD_NOT_FOUND)
        handle_transfer_from_method(msg, context);
    else if (context->selectorIndex == ATOMIC_MATCH_ && context->calldata_method == METHOD_NOT_FOUND)
        context->screen_array |= WARNING_BENEFICIARY_UI;
    // End of calldata
    if (offset + context->next_parameter_length + PARAMETER_LENGTH - SELECTOR_SIZE == msg->parameterOffset)
    {
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
        context->next_parameter_length = U2BE(msg->parameter, PARAMETER_LENGTH - 2);
        context->on_param = ON_CALLDATA;
    }

    switch ((cancel_order_parameter)context->next_param)
    {
    case EXCHANGE_ADDRESS:
    case MAKER_ADDRESS:
    case TAKER_ADDRESS:
    case FEE_RECIPIENT_ADDRESS:
        break;
    case TARGET_ADDRESS:
        copy_address(context->nft_contract_address, msg->parameter,
                     sizeof(context->nft_contract_address));
        break;
    case STATIC_TARGET_ADDRESS:
        break;
    case PAYMENT_TOKEN_ADDRESS:
        copy_address(context->payment_token_address, msg->parameter,
                     sizeof(context->payment_token_address));
        break;
    case MAKER_RELAYER_FEE:
    case TAKER_RELAYER_FEE:
    case MAKER_PROTOCOL_FEE:
    case TAKER_PROTOCOL_FEE:
        break;
    case BASE_PRICE:
        copy_parameter(context->payment_token_amount, msg->parameter,
                       sizeof(context->payment_token_amount));
        break;
    case EXTRA:
    case LISTING_TIME:
    case EXPIRATION_TIME:
    case SALT:
    case FEE_METHOD:
        break;
    case SIDE:
        // This value is either 1 or 0.
        if (msg->parameter[PARAMETER_LENGTH - 1])
            context->booleans |= ORDER_SIDE;
        break;
    case SALE_KIND:
    case HOW_TO_CALL:
        break;
    case CALLDATA_OFFSET:
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
        context->next_parameter_length = U2BE(msg->parameter, PARAMETER_LENGTH - 2);
        context->on_param = ON_CALLDATA;
    }
    // is on second calldata length
    else if (context->calldata_sell_offset != 0 && msg->parameterOffset == context->calldata_sell_offset)
    {
        context->next_parameter_length = U2BE(msg->parameter, PARAMETER_LENGTH - 2);
        context->on_param = ON_CALLDATA_SELL;
    }

    switch ((atomic_match_parameter)context->next_param)
    {
    case BUY_EXCHANGE_ADDRESS:
        break;
    case BUY_MAKER_ADDRESS:
        copy_address(context->beneficiary, msg->parameter, sizeof(context->beneficiary));
        break;
    case BUY_TAKER_ADDRESS:
        // use buy_taker_address to determine order_side
        if (!(memcmp(msg->parameter, NULL_ADDRESS, ADDRESS_LENGTH)))
            context->booleans |= ORDER_SIDE;
        break;
    case BUY_FEE_RECIPIENT_ADDRESS:
        break;
    case BUY_TARGET_ADDRESS:
        // set context->nft_contract_address, but skip if it's the proxy address
        if (memcmp(&msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH], PROXY_ADDRESS, ADDRESS_LENGTH))
            copy_address(context->nft_contract_address, msg->parameter,
                         sizeof(context->nft_contract_address));
        break;
    case BUY_STATIC_TARGET_ADDRESS:
        break;
    case BUY_PAYMENT_TOKEN_ADDRESS:
        // set context->payment_token_address
        copy_address(context->payment_token_address, msg->parameter,
                     sizeof(context->payment_token_address));
        break;
    case BUY_MAKER_RELAYER_FEE:
    case BUY_TAKER_RELAYER_FEE:
    case BUY_MAKER_PROTOCOL_FEE:
    case BUY_TAKER_PROTOCOL_FEE:
        break;
    case BUY_BASE_PRICE:
        // set context->payment_token_amount
        copy_parameter(context->payment_token_amount, msg->parameter,
                       sizeof(context->payment_token_amount));
        break;
    case BUY_EXTRA:
    case BUY_LISTING_TIME:
    case BUY_EXPIRATION_TIME:
    case BUY_SALT:
    case BUY_FEE_METHOD:
        break;
    case BUY_SIDE:
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
        break;
    case SELL_SALE_KIND:
    case SELL_HOW_TO_CALL:
        break;
    case BUY_CALLDATA_OFFSET:
        context->calldata_offset = U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE;
        break;
    case SELL_CALLDATA_OFFSET:
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

    msg->result = ETH_PLUGIN_RESULT_OK;

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
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}

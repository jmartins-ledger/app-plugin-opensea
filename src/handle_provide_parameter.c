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

// static void handle_beneficiary(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
// {
//     memset(context->beneficiary, 0, sizeof(context->beneficiary));
//     memcpy(context->beneficiary,
//            &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
//            sizeof(context->beneficiary));
//     PRINTF("BENEFICIARY: %.*H\n", ADDRESS_LENGTH, context->beneficiary);
// }

//static void handle_approve_proxy(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
//{
//    switch (context->selectorIndex)
//    {
//    case NONE:
//        break;
//    default:
//        PRINTF("Param not supported\n");
//        msg->result = ETH_PLUGIN_RESULT_ERROR;
//        break;
//    }
//}

static void handle_tranfer_from_method(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    PRINTF("IN TRANSFER METHOD.\n");
    PRINTF("IN TRANSFER METHOD.\n");
    PRINTF("calldata_offset: %d\n", context->calldata_offset);
    PRINTF("msg->offset: %d\n", msg->parameterOffset);
    // if (context->calldata_offset + context->next_parameter_length + PARAMETER_LENGTH - SELECTOR_SIZE == msg->parameterOffset)
    if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH)
        PRINTF("IN 'from' =======================================\n");
    if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 2)
        PRINTF("IN 'to' =======================================\n");
    if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 3)
    {
        PRINTF("IN 'tokenID' =======================================\n");
        memcpy(context->token_id, msg->parameter + SELECTOR_SIZE, PARAMETER_LENGTH - SELECTOR_SIZE);
    }
    if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 4)
    {
        PRINTF("IN 'tokenID' part 2 =======================================\n");
        memcpy(context->token_id + PARAMETER_LENGTH - SELECTOR_SIZE, msg->parameter, SELECTOR_SIZE);
        PRINTF("IN 'tokenID' RES: =======================================\n");
        print_bytes(context->token_id, PARAMETER_LENGTH);
    }
}

static void handle_atomicize(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    if (context->booleans & MULTIPLE_NFTS) return;
    PRINTF("====== HANDLE_ATOMICIZE ======\n");
    if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * 6)
    {
        PRINTF("penzo123 CICICICICICICICICICICICICICICICICICICICICIC???????\n");
        context->bundle_size = U4BE(msg->parameter, 0);
        memcpy(context->nft_contract_address, msg->parameter + SELECTOR_SIZE + (PARAMETER_LENGTH - ADDRESS_LENGTH), ADDRESS_LENGTH - SELECTOR_SIZE);
        PRINTF("bundle size: %d\n", context->bundle_size);
    }
    else if (msg->parameterOffset > context->calldata_offset + PARAMETER_LENGTH * 6 && msg->parameterOffset <= context->calldata_offset + PARAMETER_LENGTH * (6 + context->bundle_size)) {
        PRINTF("PENZO 1\n");
        // copy end of nft_address the first time
        if (!(context->booleans & NFT_ADDRESS_COPIED))
            memcpy(&context->nft_contract_address + (ADDRESS_LENGTH - SELECTOR_SIZE), msg->parameter, SELECTOR_SIZE);
        PRINTF("PENZO 2\n");
        // rise is_nft_address_copied
        context->booleans |= NFT_ADDRESS_COPIED;
        PRINTF("PENZO 3\n");
        if (context->booleans & NFT_ADDRESS_COPIED) {
        PRINTF("PENZO 4\n");
            // cmp start
            if (msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH * (6 + context->bundle_size)) {
        PRINTF("PENZO 5\n");
                if (memcmp(context->nft_contract_address, msg->parameter + SELECTOR_SIZE + (PARAMETER_LENGTH - ADDRESS_LENGTH), ADDRESS_LENGTH - SELECTOR_SIZE)) {
        PRINTF("PENZO 6\n");
                    context->booleans |= MULTIPLE_NFTS;
                };
            }
            // cmp end
            if (memcmp(&context->nft_contract_address + (ADDRESS_LENGTH - SELECTOR_SIZE), msg->parameter, SELECTOR_SIZE)) {
        PRINTF("PENZO 7\n");
                context->booleans |= MULTIPLE_NFTS;
            };
        }
    }
}

static void handle_calldata(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    PRINTF("IN CALLDATA IN CALL DATA target:%d =? current:%d\n", context->calldata_offset + context->next_parameter_length, msg->parameterOffset);
    // Find calldata Method ID.
    if (context->calldata_offset != 0 && msg->parameterOffset == context->calldata_offset + PARAMETER_LENGTH)
    {
        PRINTF("CALLDATA METHOD: %x%x%x%x\n", msg->parameter[0], msg->parameter[1], msg->parameter[2], msg->parameter[3]);
        uint8_t i;
        for (i = 0; i < NUM_NFT_SELECTORS; i++)
        {
            context->calldata_method = i;
            if (memcmp((uint8_t *)PIC(ERC721_SELECTORS[i]), msg->parameter, SELECTOR_SIZE) == 0)
            {
                PRINTF("CALLDATA METHOD FOUND: %d!\n", context->calldata_method);
                break;
            }
        }
    }
    if (context->calldata_method == TRANSFER_FROM ||
        context->calldata_method == SAFE_TRANSFER_FROM)
        handle_tranfer_from_method(msg, context);
    else if (context->calldata_method == ATOMICIZE)
    {
        // TODO: count items
        handle_atomicize(msg, context);
    }
    // End of calldata
    if (context->calldata_offset + context->next_parameter_length + PARAMETER_LENGTH - SELECTOR_SIZE == msg->parameterOffset)
    {
        PRINTF("END END END CALLDATA END END END\n");
        context->on_param = ON_NONE;
    }
}

static void handle_cancel_order(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    // PRINTF("\033[0;31mTEST PENZO: %x\033[0m\n", msg->parameter[PARAMETER_LENGTH]);
    PRINTF("\033[0;31mPROVIDE PARAMETER - current parameter:\n");
    print_bytes(msg->parameter, PARAMETER_LENGTH);
    PRINTF("\033[0m");
    if (context->on_param)
    {
        if (context->on_param == ON_CALLDATA)
            handle_calldata(msg, context);
    }
    // Is on calldata_length parameter
    if (context->calldata_offset != 0 && msg->parameterOffset == context->calldata_offset)
    {
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in \033[0;32mCALLDATA_LENGTH\033[0m PARAM\n");
        context->next_parameter_length = U4BE(msg->parameter, PARAMETER_LENGTH - SELECTOR_SIZE);
        PRINTF("PENZO - context->next_parameter_length = %d\n", context->next_parameter_length);
        // context->calldata_offset = 0;
        context->on_param = ON_CALLDATA;
    }
    // else if (context->replacement_pattern_offset != 0 && msg->parameterOffset == context->replacement_pattern_offset)
    // {
    //     PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in \033[0;32mREPlACEMENT_PATTERN_LENGTH\033[0m PARAM\n");
    //     context->next_parameter_length = U4BE(msg->parameter, PARAMETER_LENGTH - SELECTOR_SIZE);
    //     PRINTF("PENZO - context->next_parameter_length = %d\n", context->next_parameter_length);
    //     context->replacement_pattern_offset = 0;
    // }
    // else if (context->static_extradata_offset != 0 && msg->parameterOffset == context->static_extradata_offset)
    // {
    //     PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in \033[0;32mSTATIC_EXTRADATA_LENGTH\033[0m PARAM\n");
    //     context->next_parameter_length = U4BE(msg->parameter, PARAMETER_LENGTH - SELECTOR_SIZE);
    //     PRINTF("PENZO - context->next_parameter_length = %d\n", context->next_parameter_length);
    //     context->static_extradata_offset = 0;
    // }

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
        // If address is NULL, the payment token is ETH.
        if (memcmp(context->payment_token_address, NULL_ADDRESS, ADDRESS_LENGTH) == 0)
        {
            context->payment_token_decimals = WEI_TO_ETHER;
            strncpy(context->payment_token_ticker, "ETH ", sizeof(context->payment_token_ticker));
            context->booleans |= IS_ETH;
        }
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
        if (msg->parameter[PARAMETER_LENGTH - 1])
            context->booleans |= ORDER_SIDE;
        PRINTF("---BOOLS: %d\n", context->booleans);
        // context->calldata_offset - U4BE(msg->parameter, PARAMETER_LENGTH - 4);
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
    PRINTF("GPIRIOU NEXT PARAM !!!\n");
    context->next_param++;
}

static void handle_atomic_match(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    PRINTF("\033[0;31mPROVIDE PARAMETER - current parameter:\n");
    print_bytes(msg->parameter, PARAMETER_LENGTH);
    PRINTF("\033[0m");
    if (context->on_param)
    {
        if (context->on_param == ON_CALLDATA)
            handle_calldata(msg, context);
    }
    if (context->calldata_offset != 0 && msg->parameterOffset == context->calldata_offset)
    {
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in \033[0;32mCALLDATA_LENGTH\033[0m PARAM\n");
        context->next_parameter_length = U4BE(msg->parameter, PARAMETER_LENGTH - SELECTOR_SIZE);
        PRINTF("PENZO - context->next_parameter_length = %d\n", context->next_parameter_length);
        // context->calldata_offset = 0;
        context->on_param = ON_CALLDATA;
    }
    // else if (context->replacement_pattern_offset != 0 && msg->parameterOffset == context->replacement_pattern_offset)
    // {
    //     PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in \033[0;32mREPlACEMENT_PATTERN_LENGTH\033[0m PARAM\n");
    //     context->next_parameter_length = U4BE(msg->parameter, PARAMETER_LENGTH - SELECTOR_SIZE);
    //     PRINTF("PENZO - context->next_parameter_length = %d\n", context->next_parameter_length);
    //     context->replacement_pattern_offset = 0;
    // }
    // else if (context->static_extradata_offset != 0 && msg->parameterOffset == context->static_extradata_offset)
    // {
    //     PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in \033[0;32mSTATIC_EXTRADATA_LENGTH\033[0m PARAM\n");
    //     context->next_parameter_length = U4BE(msg->parameter, PARAMETER_LENGTH - SELECTOR_SIZE);
    //     PRINTF("PENZO - context->next_parameter_length = %d\n", context->next_parameter_length);
    //     context->static_extradata_offset = 0;
    // }

    switch ((atomic_match_parameter)context->next_param)
    {
    case BUY_EXCHANGE_ADDRESS:
    case BUY_MAKER_ADDRESS:
    case BUY_TAKER_ADDRESS:
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
        if (memcmp(context->payment_token_address, NULL_ADDRESS, ADDRESS_LENGTH) == 0)
        {
            context->payment_token_decimals = WEI_TO_ETHER;
            strncpy(context->payment_token_ticker, "ETH ", sizeof(context->payment_token_ticker));
            context->booleans |= IS_ETH;
        }
        PRINTF("GPIRIOU PAYMENT\n");
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
    case BUY_SIDE:
    case BUY_SALE_KIND:
    case BUY_HOW_TO_CALL:
    case SELL_EXCHANGE_ADDRESS:
    case SELL_MAKER_ADDRESS:
    case SELL_TAKER_ADDRESS:
    case SELL_FEE_RECIPIENT_ADDRESS:
        break;
    case SELL_TARGET_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in TARGET_ADDRESS PARAM\n");
        // set context->nft_contract_address
        copy_address(context->nft_contract_address,
                     sizeof(context->nft_contract_address),
                     msg->parameter);
        break;
    case SELL_STATIC_TARGET_ADDRESS:
        break;
    case SELL_PAYMENT_TOKEN_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in PAYMENT_TOKEN_ADDRESS PARAM\n");
        // set context->payment_token_address
        copy_address(context->payment_token_address,
                     sizeof(context->payment_token_address),
                     msg->parameter);
        break;
    case SELL_MAKER_RELAYER_FEE:
    case SELL_TAKER_RELAYER_FEE:
    case SELL_MAKER_PROTOCOL_FEE:
    case SELL_TAKER_PROTOCOL_FEE:
        break;
    case SELL_BASE_PRICE:
        PRINTF("PROVIDE_PARAMETER - handle_atomic_match - in BASE_PRICE PARAM\n");
        // set context->payment_token_amount
        copy_parameter(context->payment_token_amount,
                       sizeof(context->payment_token_amount),
                       msg->parameter);
        break;
    case SELL_EXTRA:
    case SELL_LISTING_TIME:
    case SELL_EXPIRATION_TIME:
    case SELL_SALT:
    case SELL_FEE_METHOD:
    case SELL_SIDE:
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
        context->calldata_offset = U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE;
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

    switch (context->selectorIndex)
    {
    case APPROVE_PROXY:
        // handle_approve_proxy(msg, context);
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
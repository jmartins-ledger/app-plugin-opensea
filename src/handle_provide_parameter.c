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

static void handle_beneficiary(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    memset(context->beneficiary, 0, sizeof(context->beneficiary));
    memcpy(context->beneficiary,
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
           sizeof(context->beneficiary));
    PRINTF("BENEFICIARY: %.*H\n", ADDRESS_LENGTH, context->beneficiary);
}

static void handle_approve_proxy(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    switch (context->selectorIndex)
    {
    case NONE:
        break;
    default:
        PRINTF("Param not supported\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}

static void handle_cancel_order(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    // PRINTF("\033[0;31mTEST PENZO: %x\033[0m\n", msg->parameter[PARAMETER_LENGTH]);
    PRINTF("\033[0;31mPROVIDE PARAMETER - current parameter:\n");
    print_bytes(msg->parameter, PARAMETER_LENGTH);
    PRINTF("\033[0m");
    if (context->calldata_offset != 0 && msg->parameterOffset == context->calldata_offset)
    {
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in \033[0;32mCALLDATA_LENGTH\033[0m PARAM\n");
        context->next_parameter_length = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
        PRINTF("PENZO - context->next_parameter_length = %d\n", context->next_parameter_length);
        context->calldata_offset = 0;
    }
    else if (context->replacement_pattern_offset != 0 && msg->parameterOffset == context->replacement_pattern_offset)
    {
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in \033[0;32mREPlACEMENT_PATTERN_LENGTH\033[0m PARAM\n");
        context->next_parameter_length = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
        PRINTF("PENZO - context->next_parameter_length = %d\n", context->next_parameter_length);
        context->replacement_pattern_offset = 0;
    }
    else if (context->static_extradata_offset != 0 && msg->parameterOffset == context->static_extradata_offset)
    {
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in \033[0;32mSTATIC_EXTRADATA_LENGTH\033[0m PARAM\n");
        context->next_parameter_length = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
        PRINTF("PENZO - context->next_parameter_length = %d\n", context->next_parameter_length);
        context->static_extradata_offset = 0;
    }
    switch ((cancel_order_parameter)context->next_param)
    {
    // case CONTRACT_ADDRESS:
    case EXCHANGE_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in CONTRACT_ADDRESS PARAM\n");
        break;
    case MAKER_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in MAKER_ADDRESS PARAM\n");
        break;
    case TAKER_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in TAKER_ADDRESS PARAM\n");
        break;
    case FEE_RECIPIENT_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in FEE_RECIPIENT_ADDRESS PARAM\n");
        break;
    case TARGET_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in TARGET_ADDRESS PARAM\n");
        // set context->nft_contract_address
        copy_address(context->nft_contract_address,
                     sizeof(context->nft_contract_address),
                     msg->parameter);
        break;
    case STATIC_TARGET_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in STATIC_TARGET_ADDRESS PARAM\n");
        break;
    case PAYMENT_TOKEN_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in PAYMENT_TOKEN_ADDRESS PARAM\n");
        // set context->payment_token_address
        copy_address(context->payment_token_address,
                     sizeof(context->payment_token_address),
                     msg->parameter);
        break;
    case MAKER_RELAYER_FEE:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in MAKER_RELAYER_FEE PARAM\n");
        break;
    case TAKER_RELAYER_FEE:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in TAKER_RELAYER_FEE PARAM\n");
        break;
    case MAKER_PROTOCOL_FEE:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in MAKER_PROTOCOL_FEE PARAM\n");
        break;
    case TAKER_PROTOCOL_FEE:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in TAKER_PROTOCOL_FEE PARAM\n");
        break;
    case BASE_PRICE:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in BASE_PRICE PARAM\n");
        // set context->payment_token_amount
        copy_parameter(context->payment_token_amount,
                       sizeof(context->payment_token_amount),
                       msg->parameter);
        break;
    case EXTRA:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in EXTRA PARAM\n");
        break;
    case LISTING_TIME:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in LISTING_TIME PARAM\n");
        break;
    case EXPIRATION_TIME:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in EXPIRATION_TIME PARAM\n");
        break;
    case SALT:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in SALT PARAM\n");
        break;
    case FEE_METHOD:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in FEE_METHOD PARAM\n");
        break;
    case SIDE:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in SIDE PARAM\n");
        break;
    case SALE_KIND:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in SALE_KIND PARAM\n");
        break;
    case HOW_TO_CALL:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in HOW_TO_CALL PARAM\n");
        break;
    case CALLDATA_OFFSET:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in CALLDATA_OFFSET PARAM\n");
        PRINTF("\033[0;34m OFFSETT: %d\n", U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE);
        PRINTF("\033[0m");
        context->calldata_offset = U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE;
        break;
    case REPLACEMENT_PATTERN_OFFSET:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in REPLACEMENT_PATTERN_OFFSET PARAM\n");
        PRINTF("\033[0;34m OFFSETT: %d\n", U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE);
        PRINTF("\033[0m");
        context->replacement_pattern_offset = U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE;
        break;
    case STATIC_EXTRADATA_OFFSET:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in STATIC_EXTRADATA_OFFSET PARAM\n");
        PRINTF("\033[0;34m OFFSETT: %d\n", U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE);
        PRINTF("\033[0m");
        context->static_extradata_offset = U4BE(msg->parameter, PARAMETER_LENGTH - 4) + SELECTOR_SIZE;
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
        handle_approve_proxy(msg, context);
        break;
    case CANCEL_ORDER_:
        handle_cancel_order(msg, context);
        break;
    default:
        PRINTF("Selector Index %d not supported\n", context->selectorIndex);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
#include "opensea_plugin.h"

// Prepend `dest` with `ticker`.
// Dest must be big enough to hold `ticker` + `dest` + `\0`.
static void prepend_ticker(char *dest, uint8_t destsize, char *ticker)
{
    if (dest == NULL || ticker == NULL)
    {
        THROW(0x6503);
    }
    uint8_t ticker_len = strlen(ticker);
    uint8_t dest_len = strlen(dest);

    if (dest_len + ticker_len >= destsize)
    {
        THROW(0x6503);
    }

    // Right shift the string by `ticker_len` bytes.
    while (dest_len != 0)
    {
        dest[dest_len + ticker_len] = dest[dest_len]; // First iteration will copy the \0
        dest_len--;
    }
    // Don't forget to null terminate the string.
    dest[ticker_len] = dest[0];

    // Copy the ticker to the beginning of the string.
    memcpy(dest, ticker, ticker_len);
}

static void set_tx_type_ui(ethQueryContractUI_t *msg, opensea_parameters_t *context)
{
    switch (context->selectorIndex)
    {
    case APPROVE_PROXY:
        strncpy(msg->title, "Unlock wallet:", msg->titleLength);
        strncpy(msg->msg, "Sign to unlock wallet?", msg->msgLength); /// STRING TO BE EDITED
        break;
    case CANCEL_ORDER_:
        strncpy(msg->title, "Cancel Order:", msg->titleLength);
        if (context->booleans & ORDER_SIDE)
            strncpy(msg->msg, "Withdraw offer?", msg->msgLength);
        else
            strncpy(msg->msg, "Remove listing?", msg->msgLength);
        break;
    case ATOMIC_MATCH_:
        strncpy(msg->title, "Buy now:", msg->titleLength);
        if (context->bundle_size)
            snprintf(msg->msg, msg->msgLength, "%d items", context->bundle_size);
        else
            strncpy(msg->msg, "1 item", msg->msgLength);
        break;
    default:
        break;
    }
}

static void set_collection_warning_ui(ethQueryContractUI_t *msg,
                                      opensea_parameters_t *context __attribute__((unused)))
{
    strncpy(msg->title, "Warning:", msg->titleLength);
    strncpy(msg->msg, "Unknown collection", msg->titleLength);
}

static void set_collection_ui(ethQueryContractUI_t *msg, opensea_parameters_t *context)
{
    switch (context->selectorIndex)
    {
    case CANCEL_ORDER_:
    case ATOMIC_MATCH_:
        if (context->bundle_size)
        {
            strncpy(msg->title, "Bundle:", msg->titleLength);
            snprintf(msg->msg, msg->msgLength, "%d items", context->bundle_size);
        }
        else
        {
            strncpy(msg->title, "Collection name:", msg->titleLength);
            msg->msg[0] = '0';
            msg->msg[1] = 'x';
            getEthAddressStringFromBinary((uint8_t *)context->nft_contract_address,
                                          (uint8_t *)msg->msg + 2,
                                          msg->pluginSharedRW->sha3,
                                          0);
        }
        break;
    }
}

// Set UI for "Warning" screen.
static void set_token_warning_ui(ethQueryContractUI_t *msg,
                                 opensea_parameters_t *context __attribute__((unused)))
{
    strncpy(msg->title, "Warning:", msg->titleLength);
    strncpy(msg->msg, "Unknown payment token", msg->msgLength);
}

static void set_payment_token_ui(ethQueryContractUI_t *msg, opensea_parameters_t *context)
{
    strncpy(msg->title, "Price:", msg->titleLength);
    // if (context->payment_token_address)
    // {
    amountToString(context->payment_token_amount, sizeof(context->payment_token_amount),
                   context->payment_token_decimals,
                   context->payment_token_ticker,
                   msg->msg,
                   msg->msgLength);
    // }
    // else
    // {
    //     amountToString((uint8_t *)msg->pluginSharedRO->txContent->value.value,
    //                    msg->pluginSharedRO->txContent->value.length,
    //                    WEI_TO_ETHER,
    //                    "ETH ",
    //                    msg->msg,
    //                    msg->msgLength);
    // }
}

//static void set_token_b_warning_ui(ethQueryContractUI_t *msg,
//                                   opensea_parameters_t *context __attribute__((unused)))
//{
//    strncpy(msg->title, "0000 1000", msg->titleLength);
//    strncpy(msg->msg, "! token B", msg->msgLength);
//}

//static void set_amount_eth_ui(ethQueryContractUI_t *msg, opensea_parameters_t *context)
//{
//    switch (context->selectorIndex)
//    {
//    case ADD_LIQUIDITY_ETH:
//        strncpy(msg->title, "Deposit:", msg->titleLength);
//        break;
//    case SWAP_EXACT_ETH_FOR_TOKENS:
//    case SWAP_EXACT_ETH_FOR_TOKENS_FEE:
//        strncpy(msg->title, "Swap:", msg->titleLength);
//        break;
//    }
//    amountToString((uint8_t *)msg->pluginSharedRO->txContent->value.value,
//                   msg->pluginSharedRO->txContent->value.length,
//                   WEI_TO_ETHER,
//                   "ETH ",
//                   msg->msg,
//                   msg->msgLength);
//}

static void set_beneficiary_warning_ui(ethQueryContractUI_t *msg,
                                       opensea_parameters_t *context __attribute__((unused)))
{
    strncpy(msg->title, "0010 0000", msg->titleLength);
    strncpy(msg->msg, "Not user's address", msg->titleLength);
}

// Set UI for "Beneficiary" screen.
static void set_beneficiary_ui(ethQueryContractUI_t *msg, opensea_parameters_t *context)
{
    strncpy(msg->title, "Beneficiary:", msg->titleLength);
    msg->msg[0] = '0';
    msg->msg[1] = 'x';
    // chain_config_t chainConfig = {0};
    //getEthAddressStringFromBinary((uint8_t *)context->beneficiary,
    //                              (uint8_t *)msg->msg + 2,
    //                              msg->pluginSharedRW->sha3,
    //                              0);
}

// Not used if last bit in screen array isn't 1
static void set_last_ui(ethQueryContractUI_t *msg,
                        opensea_parameters_t *context __attribute__((unused)))
{
    // Should display token id.
    strncpy(msg->title, "Token ID:", msg->titleLength);
    // long n = strtol(num, NULL, 16);
    uint256_to_decimal(context->token_id, INT256_LENGTH, msg->msg, msg->msgLength);
    // snprintf(msg->msg, msg->msgLength, "%d", (int)context->token_id);
    // snprintf(msg->msg, msg->msgLength, "%d", U4BE(context->token_id));
    // U4BE()
    // strncpy(msg->msg, "LAST", msg->titleLength);
}

static void skip_right(ethQueryContractUI_t *msg __attribute__((unused)),
                       opensea_parameters_t *context)
{
    while (!(context->screen_array & context->plugin_screen_index << 1))
    {
        context->plugin_screen_index <<= 1;
    }
}

static void skip_left(ethQueryContractUI_t *msg __attribute__((unused)),
                      opensea_parameters_t *context)
{
    while (!(context->screen_array & context->plugin_screen_index >> 1))
    {
        context->plugin_screen_index >>= 1;
    }
}

static bool get_scroll_direction(uint8_t screen_index, uint8_t previous_screen_index)
{
    if (screen_index > previous_screen_index || screen_index == 0)
        return RIGHT_SCROLL;
    else
        return LEFT_SCROLL;
}

static void get_screen_array(ethQueryContractUI_t *msg, opensea_parameters_t *context)
{
    if (msg->screenIndex == 0)
    {
        context->plugin_screen_index = TX_TYPE_UI;
        context->previous_screen_index = 0;
        return;
    }
    // This should only happen on last valid Screen
    if (msg->screenIndex == context->previous_screen_index)
    {
        context->plugin_screen_index = LAST_UI;
        if (context->screen_array & LAST_UI)
            return;
    }
    bool scroll_direction = get_scroll_direction(msg->screenIndex, context->previous_screen_index);
    // Save previous_screen_index after all checks are done.
    context->previous_screen_index = msg->screenIndex;
    // Scroll to next screen
    if (scroll_direction == RIGHT_SCROLL)
    {
        skip_right(msg, context);
        context->plugin_screen_index <<= 1;
    }
    else
    {
        skip_left(msg, context);
        context->plugin_screen_index >>= 1;
    }
}

void handle_query_contract_ui(void *parameters)
{
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    get_screen_array(msg, context);
    print_bytes(&context->plugin_screen_index, 1);
    memset(msg->title, 0, msg->titleLength);
    memset(msg->msg, 0, msg->msgLength);
    msg->result = ETH_PLUGIN_RESULT_OK;
    switch (context->plugin_screen_index)
    {
    case TX_TYPE_UI:
        PRINTF("GPIRIOU TX_TYPE\n");
        set_tx_type_ui(msg, context);
        break;
    case WARNING_COLLECTION_UI:
        PRINTF("GPIRIOU COLLECTION UI\n");
        set_collection_warning_ui(msg, context);
        break;
    case COLLECTION_UI:
        PRINTF("GPIRIOU COLLECTION UI\n");
        set_collection_ui(msg, context);
        break;
    case WARNING_TOKEN_UI:
        PRINTF("GPIRIOU COLLECTION UI\n");
        set_token_warning_ui(msg, context);
        break;
    case PAYMENT_TOKEN_UI:
        PRINTF("GPIRIOU COLLECTION UI\n");
        set_payment_token_ui(msg, context);
        break;
    case LAST_UI:
        PRINTF("GPIRIOU COLLECTION UI\n");
        set_last_ui(msg, context);
        break;
    default:
        PRINTF("GPIRIOU ERROR\n");
        break;
    }
}
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
        strncpy(msg->title, "Initialize wallet:", msg->titleLength);
        strncpy(msg->msg, "Sign to authorize wallet?", msg->msgLength); /// STRING TO BE EDITED
        break;
    case CANCEL_ORDER_:
        strncpy(msg->title, "Cancel Order:", msg->titleLength);
        if (context->booleans & ORDER_SIDE)
            strncpy(msg->msg, "Remove listing?", msg->msgLength);
        else
            strncpy(msg->msg, "Withdraw offer?", msg->msgLength);
        break;
    case ATOMIC_MATCH_:
        if (context->booleans & ORDER_SIDE)
        {
            strncpy(msg->title, "Accept", msg->titleLength);
            strncpy(msg->msg, "offer:", msg->msgLength);
        }
        else
        {
            strncpy(msg->title, "Buy", msg->titleLength);
            strncpy(msg->msg, "now:", msg->msgLength);
        }
        break;
    default:
        break;
    }
}

static void set_token_id_or_bundle_ui(ethQueryContractUI_t *msg,
                                      opensea_parameters_t *context __attribute__((unused)))
{
    switch (context->selectorIndex)
    {
    case CANCEL_ORDER_:
    case ATOMIC_MATCH_:
        if (context->calldata_method == METHOD_NOT_FOUND)
        {
            strncpy(msg->title, "Warning:", msg->titleLength);
            strncpy(msg->msg, "Unknown NFT transfer method!", msg->msgLength);
        }
        else if (context->bundle_size)
        {
            strncpy(msg->title, "Bundle:", msg->titleLength);
            snprintf(msg->msg, msg->msgLength, "%d NFT's", context->bundle_size);
        }
        else
        {
            strncpy(msg->title, "Token ID:", msg->titleLength);
            uint256_to_decimal(context->token_id, INT256_LENGTH, msg->msg, 78);
        }
        break;
    default:
        break;
    }
}

static void set_nft_name_ui(ethQueryContractUI_t *msg, opensea_parameters_t *context)
{
    switch (context->selectorIndex)
    {
    case CANCEL_ORDER_:
    case ATOMIC_MATCH_:
        if (context->booleans & MULTIPLE_NFT_ADDRESSES)
        {
            strncpy(msg->title, "Multiple NFT", msg->titleLength);
            strncpy(msg->msg, "collections.", msg->msgLength);
        }
        else
        {
            if (context->booleans & NFT_NAME_FOUND)
            {
                strncpy(msg->title, "NFT name:", msg->titleLength);
                snprintf(msg->msg, msg->msgLength, "%s", msg->item2->nft.collectionName);
            }
            else
            {
                strncpy(msg->title, "Unknown NFT:", msg->titleLength);
                msg->msg[0] = '0';
                msg->msg[1] = 'x';
                getEthAddressStringFromBinary((uint8_t *)context->nft_contract_address,
                                              (uint8_t *)msg->msg + 2,
                                              msg->pluginSharedRW->sha3,
                                              0);
            }
        }
        break;
    default:
        break;
    }
}

// Set UI for "Warning" screen.
static void set_token_warning_ui(ethQueryContractUI_t *msg,
                                 opensea_parameters_t *context __attribute__((unused)))
{
    strncpy(msg->title, "Unknown", msg->titleLength);
    strncpy(msg->msg, "payment token:", msg->titleLength);
}

static void set_token_address_ui(ethQueryContractUI_t *msg,
                                 opensea_parameters_t *context __attribute__((unused)))
{
    strncpy(msg->title, "Token address:", msg->titleLength);
    msg->msg[0] = '0';
    msg->msg[1] = 'x';
    getEthAddressStringFromBinary((uint8_t *)context->nft_contract_address,
                                  (uint8_t *)msg->msg + 2,
                                  msg->pluginSharedRW->sha3,
                                  0);
}

static void set_price_ui(ethQueryContractUI_t *msg, opensea_parameters_t *context)
{
    strncpy(msg->title, "Price:", msg->titleLength);
    amountToString(context->payment_token_amount, sizeof(context->payment_token_amount),
                   context->payment_token_decimals,
                   context->payment_token_ticker,
                   msg->msg,
                   msg->msgLength);
}

static void set_beneficiary_warning_ui(ethQueryContractUI_t *msg,
                                       opensea_parameters_t *context __attribute__((unused)))
{
    strncpy(msg->title, "Warning:", msg->titleLength);
    if (context->bundle_size)
        strncpy(msg->msg, "NFT's will not be sent to user!", msg->titleLength);
    else
        strncpy(msg->msg, "NFT will not be sent to user!", msg->titleLength);
}

// Not used if last bit in screen array isn't 1

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
    case TOKEN_ID_OR_BUNDLE_UI:
        set_token_id_or_bundle_ui(msg, context);
        PRINTF("GPIRIOU COLLECTION UI\n");
        break;
    case NFT_NAME_UI:
        PRINTF("GPIRIOU WARNING COLLECTION UI\n");
        set_nft_name_ui(msg, context);
        break;
    case UNKOWN_PAYMENT_TOKEN_UI:
        PRINTF("GPIRIOU WARNING TOKEN UI\n");
        set_token_warning_ui(msg, context);
        break;
    case UNKNOWN_TOKEN_ADDRESS_UI:
        PRINTF("GPIRIOU WARNING TOKEN UI\n");
        set_token_address_ui(msg, context);
        break;
    case PRICE_UI:
        PRINTF("GPIRIOU TOKEN ADDRESS UI\n");
        set_price_ui(msg, context);
        break;
    case WARNING_BENEFICIARY_UI:
        PRINTF("GPIRIOU WARNING BENIFICARY\n");
        set_beneficiary_warning_ui(msg, context);
        break;
    default:
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
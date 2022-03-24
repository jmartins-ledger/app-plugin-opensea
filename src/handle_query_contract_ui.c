#include "opensea_plugin.h"

static void set_tx_type_ui(ethQueryContractUI_t *msg, opensea_parameters_t *context)
{
    switch (context->selectorIndex)
    {
    case REGISTER_PROXY:
        strlcpy(msg->title, "Initialize wallet:", msg->titleLength);
        strlcpy(msg->msg, "Sign to authorize wallet?", msg->msgLength);
        break;
    case CANCEL_ORDER_:
        strlcpy(msg->title, "Cancel Order:", msg->titleLength);
        if (context->booleans & ORDER_SIDE)
            strlcpy(msg->msg, "Remove listing?", msg->msgLength);
        else
            strlcpy(msg->msg, "Withdraw offer?", msg->msgLength);
        break;
    case ATOMIC_MATCH_:
        if (context->booleans & ORDER_SIDE)
        {
            strlcpy(msg->title, "Accept", msg->titleLength);
            strlcpy(msg->msg, "Offer", msg->msgLength);
        }
        else
        {
            strlcpy(msg->title, "Buy", msg->titleLength);
            strlcpy(msg->msg, "Now", msg->msgLength);
        }
        break;
    case INCREMENT_NONCE:
        strlcpy(msg->title, "Cancel Listings:", msg->titleLength);
        strlcpy(msg->msg, "Do you wish to cancel all listings and offers?", msg->msgLength);
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
            strlcpy(msg->title, "Warning:", msg->titleLength);
            if (context->selectorIndex == ATOMIC_MATCH_)
                strlcpy(msg->msg, "Unknown NFT transfer method.", msg->msgLength);
            if (context->selectorIndex == CANCEL_ORDER_)
                strlcpy(msg->msg, "Unable to retrieve token ID.", msg->msgLength);
        }
        else if (context->bundle_size)
        {
            strlcpy(msg->title, "Bundle:", msg->titleLength);
            snprintf(msg->msg, msg->msgLength, "%d NFTs", context->bundle_size);
        }
        else
        {
            strlcpy(msg->title, "Token ID:", msg->titleLength);
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
            strlcpy(msg->title, "Multiple NFT", msg->titleLength);
            strlcpy(msg->msg, "collections.", msg->msgLength);
        }
        else
        {
            if (context->booleans & NFT_NAME_FOUND)
            {
                strlcpy(msg->title, "NFT name:", msg->titleLength);
                snprintf(msg->msg, msg->msgLength, "%s", msg->item2->nft.collectionName);
            }
            else if (!memcmp(context->nft_contract_address, NULL_ADDRESS, ADDRESS_LENGTH) || !(memcmp(PROXY_ADDRESS, context->nft_contract_address, ADDRESS_LENGTH)) || !(memcmp(ATOMICIZE_ADDRESS, context->nft_contract_address, ADDRESS_LENGTH)))
            {
                strlcpy(msg->title, "Error:", msg->titleLength);
                strlcpy(msg->msg, "Unable to retrieve NFT address.", msg->msgLength);
            }
            else
            {
                strlcpy(msg->title, "NFT address:", msg->titleLength);
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
    strlcpy(msg->title, "Unknown", msg->titleLength);
    strlcpy(msg->msg, "payment token.", msg->titleLength);
}

static void set_token_address_ui(ethQueryContractUI_t *msg,
                                 opensea_parameters_t *context __attribute__((unused)))
{
    strlcpy(msg->title, "Token address:", msg->titleLength);
    msg->msg[0] = '0';
    msg->msg[1] = 'x';
    getEthAddressStringFromBinary((uint8_t *)context->payment_token_address,
                                  (uint8_t *)msg->msg + 2,
                                  msg->pluginSharedRW->sha3,
                                  0);
}

static void set_price_ui(ethQueryContractUI_t *msg, opensea_parameters_t *context)
{
    char token_ticker[MAX_TICKER_LEN] = {0};
    uint8_t token_decimals;
    strlcpy(msg->title, "Price:", msg->titleLength);
    if (context->booleans & IS_ETH)
    {
        strlcpy(token_ticker, ETH_TICKER, sizeof(token_ticker));
        token_decimals = ETH_DECIMAL;
    }
    else if (msg->item1)
    {
        strlcpy(token_ticker, msg->item1->token.ticker, sizeof(token_ticker));
        token_decimals = msg->item1->token.decimals;
    }
    else
    {
        strlcpy(token_ticker, DEFAULT_TICKER, sizeof(token_ticker));
        token_decimals = DEFAULT_DECIMAL;
    }
    amountToString(context->payment_token_amount, sizeof(context->payment_token_amount),
                   token_decimals,
                   token_ticker,
                   msg->msg,
                   msg->msgLength);
}

static void set_beneficiary_warning_ui(ethQueryContractUI_t *msg,
                                       opensea_parameters_t *context __attribute__((unused)))
{
    strlcpy(msg->title, "Warning:", msg->titleLength);
    if (context->calldata_method == METHOD_NOT_FOUND)
        strlcpy(msg->msg, "NFTs might not be sent to you!", msg->titleLength);
    else
        strlcpy(msg->msg, "NFT will not be sent to you!", msg->titleLength);
}

static void skip_right(opensea_parameters_t *context)
{
    while (!(context->screen_array & context->plugin_screen_index << 1))
        context->plugin_screen_index <<= 1;
    context->plugin_screen_index <<= 1;
}

static void skip_left(opensea_parameters_t *context)
{
    while (!(context->screen_array & context->plugin_screen_index >> 1))
        context->plugin_screen_index >>= 1;
    context->plugin_screen_index >>= 1;
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
        // if LAST_UI is up, stop on it.
        if (context->screen_array & LAST_UI)
            return;
    }
    bool scroll_direction = get_scroll_direction(msg->screenIndex, context->previous_screen_index);
    // Save previous_screen_index after all checks are done.
    context->previous_screen_index = msg->screenIndex;
    // Scroll to next screen
    if (scroll_direction == RIGHT_SCROLL)
        skip_right(context);
    else
        skip_left(context);
}

void handle_query_contract_ui(void *parameters)
{
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    get_screen_array(msg, context);
    msg->result = ETH_PLUGIN_RESULT_OK;
    switch (context->plugin_screen_index)
    {
    case TX_TYPE_UI:
        set_tx_type_ui(msg, context);
        break;
    case TOKEN_ID_OR_BUNDLE_UI:
        set_token_id_or_bundle_ui(msg, context);
        break;
    case NFT_NAME_UI:
        set_nft_name_ui(msg, context);
        break;
    case UNKNOWN_PAYMENT_TOKEN_UI:
        set_token_warning_ui(msg, context);
        break;
    case UNKNOWN_TOKEN_ADDRESS_UI:
        set_token_address_ui(msg, context);
        break;
    case PRICE_UI:
        set_price_ui(msg, context);
        break;
    case WARNING_BENEFICIARY_UI:
        set_beneficiary_warning_ui(msg, context);
        break;
    default:
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
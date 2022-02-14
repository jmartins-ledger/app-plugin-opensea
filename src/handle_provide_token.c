#include "opensea_plugin.h"

void handle_provide_token(void *parameters)
{
    ethPluginProvideInfo_t *msg = (ethPluginProvideInfo_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    if (context->booleans & IS_ETH)
    {
        // context->payment_token_decimals = WEI_TO_ETHER;
        // strlcpy(context->payment_token_ticker, "ETH ", sizeof(context->payment_token_ticker));
    }
    // Check for payment token.
    else if (msg->item1)
    {
        // context->payment_token_decimals = msg->item1->token.decimals;
        // strlcpy(context->payment_token_ticker, (char *)msg->item1->token.ticker, sizeof(context->payment_token_ticker));
        context->booleans |= PAYMENT_TOKEN_FOUND;
    }
    else
    {
        // context->payment_token_decimals = DEFAULT_DECIMAL;
        // strlcpy(context->payment_token_ticker, DEFAULT_TICKER, sizeof(context->payment_token_ticker));
        context->screen_array |= UNKNOWN_PAYMENT_TOKEN_UI;
        msg->additionalScreens++;
        if (context->selectorIndex == ATOMIC_MATCH_)
        {
            context->screen_array |= UNKNOWN_TOKEN_ADDRESS_UI;
            msg->additionalScreens++;
        }
    }
    // check for nft info.
    if (msg->item2)
        context->booleans |= NFT_NAME_FOUND;

    msg->result = ETH_PLUGIN_RESULT_OK;
}
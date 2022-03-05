#include "opensea_plugin.h"

void handle_provide_token(void *parameters)
{
    ethPluginProvideInfo_t *msg = (ethPluginProvideInfo_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    if (!(context->booleans & IS_ETH) && msg->item1)
        context->booleans |= PAYMENT_TOKEN_FOUND;
    else if (!(context->booleans & IS_ETH))
    {
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
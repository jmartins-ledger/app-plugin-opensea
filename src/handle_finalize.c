#include "opensea_plugin.h"

static void check_beneficiary_warning(ethPluginFinalize_t *msg, opensea_parameters_t *context)
{
    if (memcmp(msg->address, context->beneficiary, ADDRESS_LENGTH))
    {
        PRINTF("GPIRIOU WARNING SET\n");
        context->screen_array |= WARNING_ADDRESS_UI;
        msg->numScreens++;
    }
}

void handle_finalize(void *parameters)
{
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    // set generic screen_array
    context->screen_array |= TX_TYPE_UI;
    if (context->selectorIndex != APPROVE_PROXY)
    {
        context->screen_array |= COLLECTION_UI;
        context->screen_array |= PAYMENT_TOKEN_UI;
    }
    // context->screen_array |= ADDRESS_UI;

    if (context->valid)
    {
        // !! condition always evaluate to true, should be false when address is 0x0
        if (context->payment_token_address)
        {
            msg->tokenLookup1 = context->payment_token_address;
        }
        msg->uiType = ETH_UI_TYPE_GENERIC;
        context->plugin_screen_index = TX_TYPE_UI;
        if (context->selectorIndex != APPROVE_PROXY)
            msg->numScreens = 3;
        else
            msg->numScreens = 1;

        // check_beneficiary_warning(msg, context);

        //msg->tokenLookup1 = context->token_a_address; // TODO: CHECK THIS
        //msg->tokenLookup2 = context->token_b_address; // TODO: CHECK THIS
        msg->result = ETH_PLUGIN_RESULT_OK;
    }
    else
    {
        PRINTF("Invalid context\n");
        msg->result = ETH_PLUGIN_RESULT_FALLBACK;
    }
}
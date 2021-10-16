#include "opensea_plugin.h"

static void check_beneficiary_warning(ethPluginFinalize_t *msg, opensea_parameters_t *context)
{
    if (memcmp(msg->address, context->beneficiary, ADDRESS_LENGTH))
    {
        PRINTF("GPIRIOU WARNING SET\n");
        context->screen_array |= WARNING_BENEFICIARY_UI;
        msg->numScreens++;
    }
}

void handle_finalize(void *parameters)
{
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    // set generic screen_array
    context->screen_array |= TX_TYPE_UI;
    switch (context->selectorIndex)
    {
    case ATOMIC_MATCH_:
    case CANCEL_ORDER_:
        context->screen_array |= NFT_NAME_UI;
        context->screen_array |= TOKEN_ID_AND_BUNDLE_UI;
        context->screen_array |= PAYMENT_TOKEN_UI;
        break;
    default:
        break;
    }
    // if (context->selectorIndex != APPROVE_PROXY)
    // {
    //     context->screen_array |= TOKEN_ID_AND_BUNDLE_UI;
    //     context->screen_array |= PAYMENT_TOKEN_UI;
    // }
    // context->screen_array |= WARNING_BENIFICIARY_UI;

    if (context->valid)
    {
        // If there is a payment_token_address
        if (memcmp(context->payment_token_address, NULL_ADDRESS, ADDRESS_LENGTH))
        {
            msg->tokenLookup1 = context->payment_token_address;
        }
        else
        {
            context->booleans |= IS_ETH;
        }
        msg->uiType = ETH_UI_TYPE_GENERIC;
        // set the first screen to display.
        context->plugin_screen_index = TX_TYPE_UI;
        switch (context->selectorIndex)
        {
        case CANCEL_ORDER_:
        case ATOMIC_MATCH_:
            msg->numScreens = 4;
            break;
        case APPROVE_PROXY:
            msg->numScreens = 1;
            break;
        default:
            break;
        }
        // if (context->selectorIndex != APPROVE_PROXY)
        //     msg->numScreens = 3;
        // else
        //     msg->numScreens = 1;

        // check_beneficiary_warning(msg, context);

        //msg->tokenLookup1 = context->token_a_address; // TODO: CHECK THIS
        //msg->tokenLookup2 = context->token_b_address; // TODO: CHECK THIS

        context->payment_token_decimals = DEFAULT_DECIMAL;
        msg->result = ETH_PLUGIN_RESULT_OK;
    }
    else
    {
        PRINTF("Invalid context\n");
        msg->result = ETH_PLUGIN_RESULT_FALLBACK;
    }
}
#include "opensea_plugin.h"

void handle_provide_token(void *parameters)
{
    ethPluginProvideToken_t *msg = (ethPluginProvideToken_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;
    PRINTF("plugin provide token: 0x%p, 0x%p\n", msg->token1, msg->token2);

    //if (context->selectorIndex == APPROVE_PROXY || context->selectorIndex == CANCEL_ORDER_)
    //{
    //    msg->result = ETH_PLUGIN_RESULT_OK;
    //    return;
    //}
    // If payment_token_address is null, payment token is ETH

    PRINTF("\033[0;31mPAYMENT_TOKEN_ADDRESS\n");
    print_bytes(context->payment_token_address, PARAMETER_LENGTH);
    PRINTF("\033[0m");
    // PRINTF("MEMCMP: %d\n", memcmp(context->payment_token_address, NULL_ADDRESS, ADDRESS_LENGTH));
    // if (memcmp(context->payment_token_address, NULL_ADDRESS, ADDRESS_LENGTH) == 0)
    // {
    // }
    // else if (msg->token1)
    if (msg->token1)
    {
        PRINTF("TOKEN1 FOUND\n");
        context->payment_token_decimals = msg->token1->decimals;
        strncpy(context->payment_token_ticker, (char *)msg->token1->ticker, sizeof(context->payment_token_ticker));
        context->booleans |= PAYMENT_TOKEN_FOUND;
    }
    else
    {
        if (context->booleans & IS_ETH)
        {
            PRINTF("NO ADDRESS, should display ETH\n");
            context->payment_token_decimals = WEI_TO_ETHER;
            strncpy(context->payment_token_ticker, "ETH ", sizeof(context->payment_token_ticker));
        }
        else
        {
            PRINTF("NOT FOUND\n");
            context->payment_token_decimals = DEFAULT_DECIMAL;
            strncpy(context->payment_token_ticker, DEFAULT_TICKER, sizeof(context->payment_token_ticker));
            context->screen_array |= WARNING_TOKEN_UI;
            msg->additionalScreens++;
        }
        // should set payment_token_found to false, but it is false by default
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
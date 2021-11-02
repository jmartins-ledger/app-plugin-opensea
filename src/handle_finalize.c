#include "opensea_plugin.h"

void handle_finalize(void *parameters)
{
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    // set generic screen_array
    context->screen_array |= TX_TYPE_UI;
    if (context->selectorIndex == ATOMIC_MATCH_ || context->selectorIndex == CANCEL_ORDER_)
    {
        context->screen_array |= NFT_NAME_UI;
        context->screen_array |= TOKEN_ID_OR_BUNDLE_UI;
        context->screen_array |= PRICE_UI;
    }

    if (context->valid)
    {
        PRINTF("BENEFICIARY:\n");
        print_bytes(context->beneficiary, PARAMETER_LENGTH);
        PRINTF("msg->address:\n");
        print_bytes(msg->address, ADDRESS_LENGTH);
        // If there is a payment_token_address
        if (memcmp(context->payment_token_address, NULL_ADDRESS, ADDRESS_LENGTH))
            msg->tokenLookup1 = context->payment_token_address;
        else
        {
            // set default token info, in case of skiped handle_provide_token()
            context->payment_token_decimals = WEI_TO_ETHER;
            strncpy(context->payment_token_ticker, "ETH ", sizeof(context->payment_token_ticker));
            context->booleans |= IS_ETH;
        }
        if (memcmp(context->nft_contract_address, NULL_ADDRESS, ADDRESS_LENGTH))
            msg->tokenLookup2 = context->nft_contract_address;
        msg->uiType = ETH_UI_TYPE_GENERIC;
        // set the first screen to display.
        context->plugin_screen_index = TX_TYPE_UI;
        switch (context->selectorIndex)
        {
        case CANCEL_ORDER_:
        case ATOMIC_MATCH_:
            msg->numScreens = 4;
            // if is a 'buy now', in atomic_match and beneficiary != sender: raise beneficiary warning
            if (!(context->booleans & ORDER_SIDE) && context->selectorIndex == ATOMIC_MATCH_ && memcmp(context->beneficiary, msg->address, ADDRESS_LENGTH))
            {
                context->screen_array |= WARNING_BENEFICIARY_UI;
                msg->numScreens++;
            }
            break;
        case APPROVE_PROXY:
            msg->numScreens = 1;
            break;
        default:
            break;
        }
        context->payment_token_decimals = DEFAULT_DECIMAL;

        msg->result = ETH_PLUGIN_RESULT_OK;
    }
    else
    {
        PRINTF("Invalid context\n");
        msg->result = ETH_PLUGIN_RESULT_FALLBACK;
    }
}
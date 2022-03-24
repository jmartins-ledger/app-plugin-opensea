#include "opensea_plugin.h"

static uint8_t count_screens(uint8_t screen_array)
{
    uint8_t total = 0;
    uint8_t scout = 1;
    for (uint8_t i = 0; i < 8; i++)
    {
        if (scout & screen_array)
            total++;
        scout <<= 1;
    }
    return total;
}

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
        // TRUE !!!
        PRINTF("PENZO is nft_address null ? %d\n", (!memcmp(context->nft_contract_address, NULL_ADDRESS, ADDRESS_LENGTH)));
        PRINTF("PENZO is COULD_NOT_PARSE && ATOMIC ? %d\n", (context->booleans & COULD_NOT_PARSE && context->selectorIndex == ATOMIC_MATCH_));
        // if is a 'buy now', in atomic_match and beneficiary != sender: raise beneficiary warning
        if ((!(context->booleans & ORDER_SIDE) && context->selectorIndex == ATOMIC_MATCH_ && memcmp(context->beneficiary, msg->address, ADDRESS_LENGTH)) || (context->booleans & COULD_NOT_PARSE && context->selectorIndex == ATOMIC_MATCH_) || (!memcmp(context->nft_contract_address, NULL_ADDRESS, ADDRESS_LENGTH)))
        {
            context->screen_array |= WARNING_BENEFICIARY_UI;
            PRINTF("PENZO 4\n");
        }
    }

    // Look for payment token info
    if (memcmp(context->payment_token_address, NULL_ADDRESS, ADDRESS_LENGTH))
        msg->tokenLookup1 = context->payment_token_address;
    // set default token info, in case of skiped handle_provide_token()
    else
        context->booleans |= IS_ETH;
    // Look foor NFT info
    if (memcmp(context->nft_contract_address, NULL_ADDRESS, ADDRESS_LENGTH))
        msg->tokenLookup2 = context->nft_contract_address;
    // set the first screen to display.
    context->plugin_screen_index = TX_TYPE_UI;
    context->payment_token_decimals = DEFAULT_DECIMAL;
    msg->uiType = ETH_UI_TYPE_GENERIC;

    // Set numScreens for each raised screens
    msg->numScreens = count_screens(context->screen_array);

    msg->result = ETH_PLUGIN_RESULT_OK;
}
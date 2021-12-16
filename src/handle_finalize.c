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
        // if is a 'buy now', in atomic_match and beneficiary != sender and is not bundle: raise beneficiary warning
        if (!(context->booleans & ORDER_SIDE) && context->selectorIndex == ATOMIC_MATCH_ && memcmp(context->beneficiary, msg->address, ADDRESS_LENGTH) && context->bundle_size || context->booleans & COULD_NOT_PARSE)
        {
            context->screen_array |= WARNING_BENEFICIARY_UI;
            PRINTF("finalize: beneficiary != user\n");
        }
        else
            PRINTF("finalize: beneficiary == user\n");
    }

    PRINTF("beneficiary:\n");
    print_bytes(context->beneficiary, PARAMETER_LENGTH);
    PRINTF("msg->address:\n");
    print_bytes(msg->address, ADDRESS_LENGTH);
    // Look for payment token info
    if (memcmp(context->payment_token_address, NULL_ADDRESS, ADDRESS_LENGTH))
        msg->tokenLookup1 = context->payment_token_address;
    else
    {
        // set default token info, in case of skiped handle_provide_token()
        context->booleans |= IS_ETH;
    }
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

    //PRINT BOOLS
    PRINTF("__BOOLEANS__\n");
    PRINTF("%d: ORDER_SIDE\n", context->booleans & ORDER_SIDE);
    PRINTF("%d: PAYMENT_TOKEN_FOUND\n", context->booleans & PAYMENT_TOKEN_FOUND);
    PRINTF("%d: IS_ETH\n", context->booleans & IS_ETH);
    PRINTF("%d: NFT_ADDRESS_COPIED\n", context->booleans & NFT_ADDRESS_COPIED);
    PRINTF("%d: MULTIPLE_NFT_ADDRESSES\n", context->booleans & MULTIPLE_NFT_ADDRESSES);
    PRINTF("%d: NFT_NAME_FOUND\n", context->booleans & NFT_NAME_FOUND);
    PRINTF("%d: COULD_NOT_PARSE\n", context->booleans & COULD_NOT_PARSE);

    //PRINT SCREENS
    PRINTF("__SCREENS__\n");
    PRINTF("%d: TX_TYPE_UI\n", context->screen_array & TX_TYPE_UI);
    PRINTF("%d: TOKEN_ID_OR_BUNDLE_UI\n", context->screen_array & TOKEN_ID_OR_BUNDLE_UI);
    PRINTF("%d: NFT_NAME_UI\n", context->screen_array & NFT_NAME_UI);
    PRINTF("%d: UNKNOWN_PAYMENT_TOKEN_UI\n", context->screen_array & UNKNOWN_PAYMENT_TOKEN_UI);
    PRINTF("%d: UNKNOWN_TOKEN_ADDRESS_UI\n", context->screen_array & UNKNOWN_TOKEN_ADDRESS_UI);
    PRINTF("%d: PRICE_UI\n", context->screen_array & PRICE_UI);
    PRINTF("%d: WARNING_BENEFICIARY_UI\n", context->screen_array & WARNING_BENEFICIARY_UI);
    PRINTF("%d: LAST_UI\n", context->screen_array & LAST_UI);
}
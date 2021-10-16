#include "opensea_plugin.h"

void handle_query_contract_id(void *parameters)
{
    ethQueryContractID_t *msg = (ethQueryContractID_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    PRINTF("ORDER_SIDE: %d\n", context->booleans & ORDER_SIDE);
    PRINTF("PAYMENT_TOKEN_FOUND: %d\n", context->booleans & PAYMENT_TOKEN_FOUND);
    PRINTF("IS_ETH: %d\n", context->booleans & IS_ETH);
    PRINTF("NFT_ADDRESS_COPIED: %d\n", context->booleans & NFT_ADDRESS_COPIED);
    PRINTF("MULTIPLE_NFT_ADDRESSES: %d\n", context->booleans & MULTIPLE_NFT_ADDRESSES);
    print_bytes(context->nft_contract_address, ADDRESS_LENGTH);

    // set 'OpenSea' title.
    strncpy(msg->name, PLUGIN_NAME, msg->nameLength);

    switch (context->selectorIndex)
    {
    case APPROVE_PROXY:
        strncpy(msg->version, "Register Proxy", msg->versionLength);
        break;
    case CANCEL_ORDER_:
        strncpy(msg->version, "Cancel Order", msg->versionLength);
        break;
    case ATOMIC_MATCH_:
        strncpy(msg->version, "Atomic Match", msg->versionLength);
        break;
    default:
        PRINTF("Selector Index :%d not supported\n", context->selectorIndex);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
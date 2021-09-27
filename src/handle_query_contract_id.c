#include "opensea_plugin.h"

void handle_query_contract_id(void *parameters)
{
    ethQueryContractID_t *msg = (ethQueryContractID_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    // set 'OpenSea' title.
    strncpy(msg->name, PLUGIN_NAME, msg->nameLength);

    switch (context->selectorIndex)
    {
    case APPROVE_PROXY:
        strncpy(msg->version, "Unlock wallet", msg->versionLength);
        break;
    default:
        PRINTF("Selector Index :%d not supported\n", context->selectorIndex);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
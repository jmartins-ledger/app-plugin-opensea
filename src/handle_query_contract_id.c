#include "opensea_plugin.h"

void handle_query_contract_id(void *parameters)
{
    ethQueryContractID_t *msg = (ethQueryContractID_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    // set 'OpenSea' title.
    strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);

    switch (context->selectorIndex)
    {
    case REGISTER_PROXY:
        strlcpy(msg->version, "Register Proxy", msg->versionLength);
        break;
    case CANCEL_ORDER_:
        strlcpy(msg->version, "Cancel Order", msg->versionLength);
        break;
    case ATOMIC_MATCH_:
        strlcpy(msg->version, "Atomic Match", msg->versionLength);
        break;
    case INCREMENT_NONCE:
        strlcpy(msg->version, "Increment Nonce", msg->versionLength);
        break;
    default:
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
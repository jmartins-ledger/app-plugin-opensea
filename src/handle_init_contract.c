#include "opensea_plugin.h"

// Called once to init.
void handle_init_contract(void *parameters)
{
    // Cast the msg to the type of structure we expect (here, ethPluginInitContract_t).
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *)parameters;

    // Make sure we are running a compatible version.
    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_LATEST)
    {
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
        return;
    }

    if (msg->pluginContextLength < sizeof(opensea_parameters_t))
    {
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    // Initialize the context (to 0).
    memset(context, 0, sizeof(*context));

    // Look for the index of the selectorIndex passed in by `msg`.
    uint8_t i;
    for (i = 0; i < NUM_OPENSEA_SELECTORS; i++)
    {
        if (memcmp((uint8_t *)PIC(OPENSEA_SELECTORS[i]), msg->selector, SELECTOR_SIZE) == 0)
        {
            context->selectorIndex = i;
            break;
        }
    }

    if (i == NUM_OPENSEA_SELECTORS)
    {
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
    }

    // Set `next_param` to be the first field we expect to parse.
    switch (context->selectorIndex)
    {
    case REGISTER_PROXY:
        break;
    case CANCEL_ORDER_:
        context->next_param = EXCHANGE_ADDRESS;
        break;
    case ATOMIC_MATCH_:
        context->next_param = BUY_EXCHANGE_ADDRESS;
        break;
    default:
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    // Return valid status.
    msg->result = ETH_PLUGIN_RESULT_OK;
}

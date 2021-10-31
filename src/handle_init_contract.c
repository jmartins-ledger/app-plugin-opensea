#include "opensea_plugin.h"

// Called once to init.
void handle_init_contract(void *parameters)
{
    // Cast the msg to the type of structure we expect (here, ethPluginInitContract_t).
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *)parameters;

    // Make sure we are running a compatible version.
    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_LATEST)
    {
        // If not the case, return the `UNAVAILABLE` status.
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
        return;
    }

    // TODO: this could be removed as this can be checked statically?
    if (msg->pluginContextLength < sizeof(opensea_parameters_t))
    {
        PRINTF("Plugin parameters structure is bigger than allowed size\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;

    // Initialize the context (to 0).
    memset(context, 0, sizeof(*context));
    // Mark context as valid.
    context->valid = 1;

    // Look for the index of the selectorIndex passed in by `msg`.
    uint8_t i;
    for (i = 0; i < NUM_OPENSEA_SELECTORS; i++)
    {
        PRINTF("\033[0;31mLOOKING for selector %d\n\033[0m", i);
        if (memcmp((uint8_t *)PIC(OPENSEA_SELECTORS[i]), msg->selector, SELECTOR_SIZE) == 0)
        {
            context->selectorIndex = i;
            break;
        }
    }

    if (i == NUM_OPENSEA_SELECTORS)
    {
        context->valid = 0;
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
    }

    // Set `next_param` to be the first field we expect to parse.
    PRINTF("INIT_CONTRACT selector: %u\n", context->selectorIndex);
    switch (context->selectorIndex)
    {
    case APPROVE_PROXY:
        break;
    case CANCEL_ORDER_:
        context->next_param = EXCHANGE_ADDRESS;
        break;
    case ATOMIC_MATCH_:
        context->next_param = BUY_EXCHANGE_ADDRESS;
        break;
    default:
        PRINTF("Missing selectorIndex\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    // Return valid status.
    msg->result = ETH_PLUGIN_RESULT_OK;
}

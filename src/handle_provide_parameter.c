#include "opensea_plugin.h"

static void handle_beneficiary(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    memset(context->beneficiary, 0, sizeof(context->beneficiary));
    memcpy(context->beneficiary,
           &msg->parameter[PARAMETER_LENGTH - ADDRESS_LENGTH],
           sizeof(context->beneficiary));
    PRINTF("BENEFICIARY: %.*H\n", ADDRESS_LENGTH, context->beneficiary);
}

static void handle_approve_proxy(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    switch (context->selectorIndex)
    {
    case NONE:
        break;
    default:
        PRINTF("Param not supported\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}

static void handle_cancel_order(ethPluginProvideParameter_t *msg, opensea_parameters_t *context)
{
    // PRINTF("\033[0;31mTEST PENZO: %x\033[0m\n", msg->parameter[PARAMETER_LENGTH]);
    PRINTF("\033[0;31mPROVIDE PARAMETER - current parameter:\n");
    print_bytes(msg->parameter, PARAMETER_LENGTH);
    PRINTF("\033[0m");
    switch (context->next_param)
    {
    case CONTRACT_ADDRESS:
        PRINTF("PROVIDE_PARAMETER - handle_cancel_order - in CONTRACT_ADDRESS PARAM\n");
        context->next_param++;
        break;
    default:
        break;
    }
}

void handle_provide_parameter(void *parameters)
{
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *)parameters;
    opensea_parameters_t *context = (opensea_parameters_t *)msg->pluginContext;
    PRINTF("PROVIDE PARAMETER, selector: %d\n", context->selectorIndex);

    msg->result = ETH_PLUGIN_RESULT_OK;

    switch (context->selectorIndex)
    {
    case APPROVE_PROXY:
        handle_approve_proxy(msg, context);
        break;
    case CANCEL_ORDER_:
        handle_cancel_order(msg, context);
        break;
    default:
        PRINTF("Selector Index %d not supported\n", context->selectorIndex);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
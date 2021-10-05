/*******************************************************************************
 *   Ethereum 2 Deposit Application
 *   (c) 2020 Ledger
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/

#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#include "os.h"
#include "cx.h"
#include "opensea_plugin.h"

// Define here all the selectors you wish to support.

//OpenSea Contract Methods
static const uint8_t OPENSEA_APPROVE_PROXY[SELECTOR_SIZE] = {0xdd, 0xd8, 0x1f, 0x82};
static const uint8_t OPENSEA_CANCEL_ORDER_[SELECTOR_SIZE] = {0xa8, 0xa4, 0x1c, 0x70};
static const uint8_t OPENSEA_ATOMIC_MATCH_[SELECTOR_SIZE] = {0xab, 0x83, 0x4b, 0xab};

// Array of all the different opensea selectors. Make sure this follows the same order as the
// enum defined in `opensea_plugin.h`
const uint8_t *const OPENSEA_SELECTORS[NUM_OPENSEA_SELECTORS] = {
    OPENSEA_APPROVE_PROXY,
    OPENSEA_CANCEL_ORDER_,
    OPENSEA_ATOMIC_MATCH_,
};

// ERC721 Standards Methods
static const uint8_t _TRANSFER_FROM[SELECTOR_SIZE] = {0x23, 0xb8, 0x72, 0xdd};

// Array of all the different ERC721 selectors. Make sure this follows the same order as the
// enum defined in `opensea_plugin.h`
const uint8_t *const ERC721_SELECTORS[NUM_NFT_SELECTORS] = {
    _TRANSFER_FROM,
};

// Function to dispatch calls from the ethereum app.
void dispatch_plugin_calls(int message, void *parameters)
{
    PRINTF("just in: message: %d\n", message);
    switch (message)
    {
    case ETH_PLUGIN_INIT_CONTRACT:
        PRINTF("\033[0;32mINIT CONTRACT\n\033[0m");
        handle_init_contract(parameters);
        break;
    case ETH_PLUGIN_PROVIDE_PARAMETER:
        PRINTF("\033[0;32mPROVIDE PARAMETER\n\033[0m");
        handle_provide_parameter(parameters);
        break;
    case ETH_PLUGIN_FINALIZE:
        PRINTF("\033[0;32mFINALIZE\n\033[0m");
        handle_finalize(parameters);
        break;
    case ETH_PLUGIN_PROVIDE_TOKEN:
        PRINTF("\033[0;32mPROVIDE TOKEN\n\033[0m");
        handle_provide_token(parameters);
        break;
    case ETH_PLUGIN_QUERY_CONTRACT_ID:
        PRINTF("\033[0;32mQUERY CONTRACT ID\n\033[0m");
        handle_query_contract_id(parameters);
        break;
    case ETH_PLUGIN_QUERY_CONTRACT_UI:
        PRINTF("\033[0;32mQUERY CONTRACT UI\n\033[0m");
        handle_query_contract_ui(parameters);
        break;
    default:
        PRINTF("\033[0;32mUnhandled message %d\n\033[0m", message);
        break;
    }
}

// Calls the ethereum app.
void call_app_ethereum()
{
    unsigned int libcall_params[3];
    libcall_params[0] = (unsigned int)"Ethereum";
    libcall_params[1] = 0x100;
    libcall_params[2] = RUN_APPLICATION;
    os_lib_call((unsigned int *)&libcall_params);
}

// Weird low-level black magic.
__attribute__((section(".boot"))) int main(int arg0)
{
    // Low-level black magic, don't touch.
    // exit critical section
    __asm volatile("cpsie i");

    // Low-level black magic, don't touch.
    // ensure exception will work as planned
    os_boot();

    // Try catch block. Please read the docs for more information on how to use those!
    BEGIN_TRY
    {
        TRY
        {
            // Low-level black magic. Don't touch.
            check_api_level(CX_COMPAT_APILEVEL);

            // Check if we are called from the dashboard.
            if (!arg0)
            {
                // called from dashboard, launch Ethereum app
                call_app_ethereum();
                return 0;
            }
            else
            {
                // not called from dashboard: called from the ethereum app!
                unsigned int *args = (unsigned int *)arg0;

                // If `ETH_PLUGIN_CHECK_PRESENCE`, we can skip `dispatch_plugin_calls`.
                if (args[0] != ETH_PLUGIN_CHECK_PRESENCE)
                {
                    dispatch_plugin_calls(args[0], (void *)args[1]);
                }

                // Call `os_lib_end`, go back to the ethereum app.
                os_lib_end();
            }
        }
        FINALLY
        {
        }
    }
    END_TRY;

    // Will not get reached.
    return 0;
}

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

// OpenSea Contract Methods
static const uint8_t OPENSEA_REGISTER_PROXY[SELECTOR_SIZE] = {0xdd, 0xd8, 0x1f, 0x82};
static const uint8_t OPENSEA_CANCEL_ORDER_[SELECTOR_SIZE] = {0xa8, 0xa4, 0x1c, 0x70};
static const uint8_t OPENSEA_ATOMIC_MATCH_[SELECTOR_SIZE] = {0xab, 0x83, 0x4b, 0xab};
static const uint8_t OPENSEA_INCREMENT_NONCE[SELECTOR_SIZE] = {0x62, 0x7c, 0xdc, 0xb9};

// Array of all the different opensea selectors. Make sure this follows the same order as the
// enum defined in `opensea_plugin.h`
const uint8_t *const OPENSEA_SELECTORS[NUM_OPENSEA_SELECTORS] = {
    OPENSEA_REGISTER_PROXY,
    OPENSEA_CANCEL_ORDER_,
    OPENSEA_ATOMIC_MATCH_,
    OPENSEA_INCREMENT_NONCE,
};

// ERC721 and ERC1155 Standards Methods + V2 OpenWyvern transfer methods.
static const uint8_t _TRANSFER_FROM[SELECTOR_SIZE] = {0x23, 0xb8, 0x72, 0xdd};
static const uint8_t _SAFE_TRANSFER_FROM[SELECTOR_SIZE] = {0x42, 0x84, 0x2e, 0x0e};
static const uint8_t _SAFE_TRANSFER_FROM_DATA_721[SELECTOR_SIZE] = {0xb8, 0x8d, 0x4f, 0xde};
static const uint8_t _TRANSFER[SELECTOR_SIZE] = {0x30, 0xe0, 0x78, 0x9e};
static const uint8_t _ATOMICIZE[SELECTOR_SIZE] = {0x68, 0xf0, 0xbc, 0xaa};
static const uint8_t _SAFE_TRANSFER_FROM_DATA_1155[SELECTOR_SIZE] = {0xf2, 0x42, 0x43, 0x2a};
static const uint8_t _MATCH_ERC721_USING_CRITERIA[SELECTOR_SIZE] = {0xfb, 0x16, 0xa5, 0x95};
static const uint8_t _MATCH_ERC721_WITH_SAFE_TRANSFER_USING_CRITERIA[SELECTOR_SIZE] = {0xc5, 0xa0, 0x23, 0x6e};
static const uint8_t _MATCH_ERC1155_USING_CRITERIA[SELECTOR_SIZE] = {0x96, 0x80, 0x9f, 0x90};
static const uint8_t _METHOD_NOT_FOUND[SELECTOR_SIZE] = {0x00, 0x00, 0x00, 0x00};

// Opensea contracts addresses
const uint8_t PROXY_ADDRESS[ADDRESS_LENGTH] = {0xba, 0xf2, 0x12, 0x7b, 0x49, 0xfc, 0x93, 0xcb, 0xca, 0x62, 0x69, 0xfa, 0xde, 0x0f, 0x7f, 0x31, 0xdf, 0x4c, 0x88, 0xa7};
const uint8_t ATOMICIZE_ADDRESS[ADDRESS_LENGTH] = {0xc9, 0x9f, 0x70, 0xbf, 0xd8, 0x2f, 0xb7, 0xc8, 0xf8, 0x19, 0x1f, 0xdf, 0xbf, 0xb7, 0x35, 0x60, 0x6b, 0x15, 0xe5, 0xc5};

// Array of all the different ERC721 selectors. Make sure this follows the same order as the
// enum defined in `opensea_plugin.h`
const uint8_t *const ERC721_SELECTORS[NUM_NFT_SELECTORS] = {
    _TRANSFER_FROM,
    _SAFE_TRANSFER_FROM,
    _SAFE_TRANSFER_FROM_DATA_721,
    _TRANSFER,
    _ATOMICIZE,
    _SAFE_TRANSFER_FROM_DATA_1155,
    _MATCH_ERC721_USING_CRITERIA,
    _MATCH_ERC721_WITH_SAFE_TRANSFER_USING_CRITERIA,
    _MATCH_ERC1155_USING_CRITERIA,
    _METHOD_NOT_FOUND,
};

// Function to dispatch calls from the ethereum app.
void dispatch_plugin_calls(int message, void *parameters)
{
    switch (message)
    {
    case ETH_PLUGIN_INIT_CONTRACT:
        handle_init_contract(parameters);
        break;
    case ETH_PLUGIN_PROVIDE_PARAMETER:
        handle_provide_parameter(parameters);
        break;
    case ETH_PLUGIN_FINALIZE:
        handle_finalize(parameters);
        break;
    case ETH_PLUGIN_PROVIDE_INFO:
        handle_provide_token(parameters);
        break;
    case ETH_PLUGIN_QUERY_CONTRACT_ID:
        handle_query_contract_id(parameters);
        break;
    case ETH_PLUGIN_QUERY_CONTRACT_UI:
        handle_query_contract_ui(parameters);
        break;
    default:
        break;
    }
}

void handle_query_ui_exception(unsigned int *args) {
    switch (args[0]) {
        case ETH_PLUGIN_QUERY_CONTRACT_UI:
            ((ethQueryContractUI_t *) args[1])->result = ETH_PLUGIN_RESULT_ERROR;
            break;
        default:
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
            }
        }
        CATCH_OTHER(e) {
            switch (e) {
                // These exceptions are only generated on handle_query_contract_ui()
                case 0x6502:
                case EXCEPTION_OVERFLOW:
                    handle_query_ui_exception((unsigned int *) arg0);
                    break;
                default:
                    break;
            }
            PRINTF("Exception 0x%x caught\n", e);
        }
        FINALLY
        {
            // Call `os_lib_end`, go back to the ethereum app.
            os_lib_end();
        }
    }
    END_TRY;

    // Will not get reached.
    return 0;
}

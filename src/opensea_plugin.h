#pragma once

#include "eth_internals.h"
#include "eth_plugin_interface.h"
#include <string.h>

// Size of parameters passed in by the Ethereum app. No need to modify it. TODO: move it to
// `eth_plugin_interals.h`.
#define PARAMETER_LENGTH 32

// Size of the smart-contract method. No need to modify it. TODO: mov eit to
// `eth_plugin_interals.h`.
#define SELECTOR_SIZE 4

// Value to be passed in as parameter when calling the Ethereum app. TODO: mov eit to
// `eth_plugin_interals.h`.
#define RUN_APPLICATION 1

// Name of the plugin.
#define PLUGIN_NAME "OpenSea"

// Number of selectors defined in this plugin.
#define NUM_OPENSEA_SELECTORS 2

// Enumeration of the different selectors possible.
// Should follow the array declared in main.c
typedef enum
{
    APPROVE_PROXY,
    CANCEL_ORDER_,
} openseaSelector_t;

#define NUM_NFT_SELECTORS 1
typedef enum
{
    TRANSFER_FROM,
} erc721Selector_t;

extern const uint8_t *const OPENSEA_SELECTORS[NUM_OPENSEA_SELECTORS];
extern const uint8_t *const ERC721_SELECTORS[NUM_NFT_SELECTORS];

// screeen array correspondance
#define TX_TYPE_UI 1
#define WARNING_TOKEN_A_UI (1 << 1)
#define AMOUNT_TOKEN_A_UI (1 << 2)
#define WARNING_TOKEN_B_UI (1 << 3)
#define AMOUNT_TOKEN_B_UI (1 << 4)
#define WARNING_ADDRESS_UI (1 << 5)
#define ADDRESS_UI (1 << 6)
#define LAST_UI (1 << 7)

#define RIGHT_SCROLL 1
#define LEFT_SCROLL 0

// Enumeration used to parse the smart-contract data.
typedef enum
{
    BENEFICIARY,
    CONTRACT_ADDRESS,
    DEADLINE,
    NONE,
} selectorField;

typedef enum
{
    NOOP,
    EXCHANGE_ADDRESS, // 7 Addresses
    MAKER_ADDRESS,
    TAKER_ADDRESS,
    FEE_RECIPIENT_ADDRESS,
    TARGET_ADDRESS,
    STATIC_TARGET_ADDRESS,
    PAYMENT_TOKEN_ADDRESS,
    MAKER_RELAYER_FEE, // 9 uint256
    TAKER_RELAYER_FEE,
    MAKER_PROTOCOL_FEE,
    TAKER_PROTOCOL_FEE,
    BASE_PRICE,
    EXTRA,
    LISTING_TIME,
    EXPIRATION_TIME,
    SALT,
    FEE_METHOD,
    SIDE,
    SALE_KIND,
    HOW_TO_CALL,
    CALLDATA_OFFSET,
    REPLACEMENT_PATTERN_OFFSET,
    STATIC_EXTRADATA_OFFSET,
    CALLDATA,
    REPLACEMENT_PATTERN,
    STATIC_EXTRADATA,
    // SIG stuff
} cancel_order_parameter;

#define WETH_TICKER "WETH"
#define WETH_DECIMALS 18

// Number of decimals used when the token wasn't found in the Crypto Asset List.
#define DEFAULT_DECIMAL WEI_TO_ETHER

// Ticker used when the token wasn't found in the Crypto Asset List.
#define DEFAULT_TICKER "? "

// on_param defines
#define ON_NONE 0
#define ON_CALLDATA 1
#define ON_REPLACEMENT_PATTERN (1 << 1)
#define ON_STATIC_EXTRADATA (1 << 2)

// Shared global memory with Ethereum app. Must be at most 5 * 32 bytes.
typedef struct opensea_parameters_t
{
    uint16_t calldata_offset;            // 2
    uint16_t replacement_pattern_offset; // 2
    uint16_t static_extradata_offset;    // 2
    uint32_t next_parameter_length;      // 4
    uint8_t on_param;                    // 1

    uint8_t payment_token_address[ADDRESS_LENGTH]; // 20
    uint8_t payment_token_amount[INT256_LENGTH];   // 32
    char payment_token_ticker[MAX_TICKER_LEN];     // 12
    uint8_t payment_token_decimals;                // 1
    bool payment_token_found;                      // 1
    uint8_t beneficiary[ADDRESS_LENGTH];           // 20

    uint8_t token_id[INT256_LENGTH]; // 32

    uint8_t side;                                 // 1
    uint8_t nft_contract_address[ADDRESS_LENGTH]; // 20
    // token id

    uint8_t screen_array;          // 1
    uint8_t previous_screen_index; // 1
    uint8_t plugin_screen_index;   // 1

    uint8_t skip;          // 1
    uint8_t next_param;    // 1
    uint8_t valid;         // 1
    uint8_t selectorIndex; // 1
    // = 157
} opensea_parameters_t;

// Piece of code that will check that the above structure is not bigger than 5 * 32. Do not remove
// this check.
// TODO: unify this with the check in ethPluginInitContract.
_Static_assert(sizeof(opensea_parameters_t) <= 5 * 32, "Structure of parameters too big.");

void handle_provide_parameter(void *parameters);
void handle_query_contract_ui(void *parameters);
void handle_init_contract(void *parameters);
void handle_finalize(void *parameters);
void handle_provide_token(void *parameters);
void handle_query_contract_id(void *parameters);
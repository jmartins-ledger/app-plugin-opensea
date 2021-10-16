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
#define NUM_OPENSEA_SELECTORS 3

// Enumeration of the different selectors possible.
// Should follow the array declared in main.c
typedef enum
{
    APPROVE_PROXY,
    CANCEL_ORDER_,
    ATOMIC_MATCH_,
} openseaSelector_t;

#define NUM_NFT_SELECTORS 4

typedef enum
{
    TRANSFER_FROM,
    SAFE_TRANSFER_FROM,
    ATOMICIZE,
    METHOD_NOT_FOUND,
} erc721Selector_t;

typedef enum
{
    FROM,
    TO,
    TOKEN_ID,
} transfer_from_parameter;

extern const uint8_t *const OPENSEA_SELECTORS[NUM_OPENSEA_SELECTORS];
extern const uint8_t *const ERC721_SELECTORS[NUM_NFT_SELECTORS];

// screeen array correspondance
#define TX_TYPE_UI 1 // Must remain first screen in screen array.
#define TOKEN_ID_AND_BUNDLE_UI (1 << 1)
#define NFT_NAME_UI (1 << 2)

#define WARNING_PAYMENT_TOKEN_UI (1 << 3)
#define PAYMENT_TOKEN_UI (1 << 4)

#define WARNING_BENEFICIARY_UI (1 << 5)

#define UNUSED_UI (1 << 6)
#define LAST_UI (1 << 7) // Must remain last screen in screen array.

#define RIGHT_SCROLL 1
#define LEFT_SCROLL 0

#define NULL_ADDRESS "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

// cancelOrder_() parameters
typedef enum
{
    A_NOOP,
    EXCHANGE_ADDRESS, // 7 Addresses
    MAKER_ADDRESS,
    TAKER_ADDRESS,
    FEE_RECIPIENT_ADDRESS,
    TARGET_ADDRESS,
    STATIC_TARGET_ADDRESS,
    PAYMENT_TOKEN_ADDRESS,
    MAKER_RELAYER_FEE, // 9 uint256 {
    TAKER_RELAYER_FEE,
    MAKER_PROTOCOL_FEE,
    TAKER_PROTOCOL_FEE,
    BASE_PRICE,
    EXTRA,
    LISTING_TIME,
    EXPIRATION_TIME,
    SALT, // }
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

typedef enum
{
    B_NOOP,
    BUY_EXCHANGE_ADDRESS, // 14 Addresses
    BUY_MAKER_ADDRESS,
    BUY_TAKER_ADDRESS,
    BUY_FEE_RECIPIENT_ADDRESS,
    BUY_TARGET_ADDRESS,
    BUY_STATIC_TARGET_ADDRESS,
    BUY_PAYMENT_TOKEN_ADDRESS,

    SELL_EXCHANGE_ADDRESS,
    SELL_MAKER_ADDRESS,
    SELL_TAKER_ADDRESS,
    SELL_FEE_RECIPIENT_ADDRESS,
    SELL_TARGET_ADDRESS,
    SELL_STATIC_TARGET_ADDRESS,
    SELL_PAYMENT_TOKEN_ADDRESS, // }

    BUY_MAKER_RELAYER_FEE, // 18 uint256 {
    BUY_TAKER_RELAYER_FEE,
    BUY_MAKER_PROTOCOL_FEE,
    BUY_TAKER_PROTOCOL_FEE,
    BUY_BASE_PRICE,
    BUY_EXTRA,
    BUY_LISTING_TIME,
    BUY_EXPIRATION_TIME,
    BUY_SALT,

    SELL_MAKER_RELAYER_FEE,
    SELL_TAKER_RELAYER_FEE,
    SELL_MAKER_PROTOCOL_FEE,
    SELL_TAKER_PROTOCOL_FEE,
    SELL_BASE_PRICE,
    SELL_EXTRA,
    SELL_LISTING_TIME,
    SELL_EXPIRATION_TIME,
    SELL_SALT, // }

    BUY_FEE_METHOD, // 8 uint256 {
    BUY_SIDE,
    BUY_SALE_KIND,
    BUY_HOW_TO_CALL,

    SELL_FEE_METHOD,
    SELL_SIDE,
    SELL_SALE_KIND,
    SELL_HOW_TO_CALL, // }

    BUY_CALLDATA_OFFSET,
    SELL_CALLDATA_OFFSET,

    BUY_REPLACEMENT_PATTERN_OFFSET,
    SELL_REPLACEMENT_PATTERN_OFFSET,

    BUY_STATIC_EXTRADATA_OFFSET,
    SELL_STATIC_EXTRADATA_OFFSET,

    BUY_CALLDATA,
    SELL_CALLDATA,

    BUY_REPLACEMENT_PATTERN,
    SELL_REPLACEMENT_PATTERN,

    BUY_STATIC_EXTRADATA,
    SELL_STATIC_EXTRADATA,
    // Buy sig stuff
    // Sell sig stuff
} atomic_match_parameter;

#define WETH_TICKER "WETH"
#define WETH_DECIMALS 18

// Number of decimals used when the token wasn't found in the Crypto Asset List.
#define DEFAULT_DECIMAL WEI_TO_ETHER

// Ticker used when the token wasn't found in the Crypto Asset List.
#define DEFAULT_TICKER "? "

// on_param defines
// PENZO useless bit shifting, this should be 1, 2, 3...
#define ON_NONE 0
#define ON_CALLDATA 1
#define ON_REPLACEMENT_PATTERN (1 << 1)
#define ON_STATIC_EXTRADATA (1 << 2)

// Booleans
#define SKIP 1
#define ORDER_SIDE (1 << 1)
#define PAYMENT_TOKEN_FOUND (1 << 2)
#define IS_ETH (1 << 3)
#define NFT_ADDRESS_COPIED (1 << 4)
#define MULTIPLE_NFT_ADDRESSES (1 << 5)
#define NAME_FOUND (1 << 6)

// Shared global memory with Ethereum app. Must be at most 5 * 32 bytes.
typedef struct opensea_parameters_t
{
    uint8_t booleans;         // 1
    uint16_t calldata_offset; // 2
    // uint16_t replacement_pattern_offset; // 2
    // uint16_t static_extradata_offset;    // 2
    uint32_t next_parameter_length; // 4
    uint8_t on_param;               // 1
    uint8_t calldata_method;        // 1

    uint8_t payment_token_address[ADDRESS_LENGTH]; // 20
    uint8_t payment_token_amount[INT256_LENGTH];   // 32
    char payment_token_ticker[MAX_TICKER_LEN];     // 12
    uint8_t payment_token_decimals;                // 1
    // uint8_t payment_token_found;                   // 1
    uint8_t beneficiary[ADDRESS_LENGTH]; // 20

    // uint8_t side;                               // 1
    uint8_t nft_contract_address[ADDRESS_LENGTH]; // 20
    uint8_t token_id[INT256_LENGTH];              // 32
    // !! Risky uint8_t for size
    uint8_t bundle_size; // 1

    uint8_t screen_array;          // 1
    uint8_t previous_screen_index; // 1
    uint8_t plugin_screen_index;   // 1

    uint8_t skip;          // 1
    uint8_t next_param;    // 1
    uint8_t valid;         // 1
    uint8_t selectorIndex; // 1
} opensea_parameters_t;
// = 159

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
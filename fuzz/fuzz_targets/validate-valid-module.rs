#![no_main]

use libfuzzer_sys::fuzz_target;
use wasm_smith::{ConfiguredModule, SwarmConfig};

// Define a fuzz target that accepts arbitrary
// `Module`s as input.
fuzz_target!(|m: ConfiguredModule<SwarmConfig>| {
    // Convert the module into Wasm bytes.
    let bytes = m.to_bytes();

    // Validate the module and assert that it passes
    // validation.
    let mut validator = wasmparser::Validator::new();
    validator.wasm_features(wasmparser::WasmFeatures {
        multi_value: true,
        multi_memory: true,
        bulk_memory: true,
        reference_types: true,
        module_linking: true,
        ..wasmparser::WasmFeatures::default()
    });
    if let Err(e) = validator.validate_all(&bytes) {
        std::fs::write("test.wasm", bytes).unwrap();
        panic!("Invalid module: {}", e);
    }
});

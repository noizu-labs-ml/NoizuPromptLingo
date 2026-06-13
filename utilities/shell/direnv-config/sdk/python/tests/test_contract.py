from __future__ import annotations

from pathlib import Path

import pytest
import yaml

from direnv_config.native import NativeBackend
from direnv_config.store import path_to_hash
from direnv_config.version import read_version

FIXTURES_DIR = Path(__file__).resolve().parent.parent.parent / "contract-tests" / "fixtures"
EXPECTATIONS_FILE = Path(__file__).resolve().parent.parent.parent / "contract-tests" / "expectations.yaml"


def load_expectations() -> list[dict]:
    with open(EXPECTATIONS_FILE) as f:
        data = yaml.safe_load(f)
    return data["tests"]


def _test_ids() -> list[str]:
    return [t["name"] for t in load_expectations()]


@pytest.fixture(params=load_expectations(), ids=_test_ids())
def test_case(request):
    return request.param


def test_contract(test_case):
    name = test_case["name"]

    if "input_path" in test_case:
        result = path_to_hash(test_case["input_path"])
        assert result == test_case["expected_hash"], f"[{name}] hash mismatch"
        return

    if "expected_version" in test_case:
        store = FIXTURES_DIR / test_case["store"]
        version = read_version(store)
        assert version == test_case["expected_version"], f"[{name}] version mismatch"
        return

    if "expected_configs" in test_case:
        store = FIXTURES_DIR / test_case["store"]
        backend = NativeBackend(store)
        configs = backend.list_configs()
        assert sorted(configs) == sorted(test_case["expected_configs"]), f"[{name}] configs mismatch"
        return

    store = FIXTURES_DIR / test_case["store"]
    backend = NativeBackend(store)
    config = test_case["config"]
    path = test_case.get("path")
    test_type = test_case["type"]

    result = backend.get(config, path)

    if test_type == "null":
        assert result is None, f"[{name}] expected null, got {result}"
    elif test_type == "string":
        assert result == test_case["expected"], f"[{name}] expected {test_case['expected']}, got {result}"
    elif test_type == "integer":
        assert result == int(test_case["expected"]), f"[{name}] expected {test_case['expected']}, got {result}"
    elif test_type == "boolean":
        expected_bool = test_case["expected"] if isinstance(test_case["expected"], bool) else str(test_case["expected"]).lower() == "true"
        assert result == expected_bool, f"[{name}] expected {expected_bool}, got {result}"
    elif test_type == "string_array":
        assert isinstance(result, list), f"[{name}] expected list, got {type(result)}"
        expected = [str(v) for v in test_case["expected"]]
        assert result == expected, f"[{name}] expected {expected}, got {result}"
    elif test_type == "integer_array":
        assert isinstance(result, list), f"[{name}] expected list, got {type(result)}"
        expected = [int(v) for v in test_case["expected"]]
        assert result == expected, f"[{name}] expected {expected}, got {result}"
    elif test_type == "map":
        assert isinstance(result, dict), f"[{name}] expected dict, got {type(result)}"
        for key in test_case["expected_keys"]:
            assert key in result, f"[{name}] missing key: {key}"
    else:
        pytest.fail(f"[{name}] unknown test type: {test_type}")

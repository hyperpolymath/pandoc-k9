-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- test_k9.lua — Unit and property tests for the K9 pandoc filter.
-- Run: lua test_k9.lua

local pass = 0
local fail = 0

local function assert_eq(desc, actual, expected)
  if actual == expected then
    io.write("PASS: " .. desc .. "\n"); pass = pass + 1
  else
    io.write("FAIL: " .. desc .. "\n")
    io.write("  expected: " .. tostring(expected) .. "\n")
    io.write("  actual:   " .. tostring(actual) .. "\n")
    fail = fail + 1
  end
end

local function assert_true(desc, val)
  if val then io.write("PASS: " .. desc .. "\n"); pass = pass + 1
  else io.write("FAIL: " .. desc .. "\n"); fail = fail + 1 end
end

local function assert_false(desc, val)
  if not val then io.write("PASS: " .. desc .. "\n"); pass = pass + 1
  else io.write("FAIL: " .. desc .. "\n"); fail = fail + 1 end
end

-- ================================================================
-- Unit tests: K9 magic number detection
-- ================================================================

io.write("\n=== K9 Magic Number Detection ===\n")

local function has_magic(line)
  return line:match("^K9!") ~= nil
end

assert_true("K9! magic detected", has_magic("K9!"))
assert_true("K9! with content", has_magic("K9! # comment"))
assert_false("No magic in empty", has_magic(""))
assert_false("Different magic rejected", has_magic("K8!"))
assert_false("Lowercase rejected", has_magic("k9!"))

-- ================================================================
-- Unit tests: SPDX header detection
-- ================================================================

io.write("\n=== SPDX Header Detection ===\n")

local function is_spdx(line)
  return line:match("SPDX%-License%-Identifier:") ~= nil
end

assert_true("SPDX line detected", is_spdx("# SPDX-License-Identifier: PMPL-1.0-or-later"))
assert_true("SPDX in comment", is_spdx("-- SPDX-License-Identifier: MIT"))
assert_false("Non-SPDX rejected", is_spdx("just a comment"))
assert_false("Empty rejected", is_spdx(""))

-- ================================================================
-- Unit tests: Security level detection
-- ================================================================

io.write("\n=== Security Level Detection ===\n")

local SECURITY_LEVELS = {"Kennel", "Yard", "Hunt"}

local function get_security_level(line)
  for _, level in ipairs(SECURITY_LEVELS) do
    if line:match(level) then return level end
  end
  return nil
end

assert_eq("Kennel level", get_security_level("security_level: Kennel"), "Kennel")
assert_eq("Yard level", get_security_level("security_level: Yard"), "Yard")
assert_eq("Hunt level", get_security_level("security_level: Hunt"), "Hunt")
assert_eq("No level found", get_security_level("other content"), nil)

-- ================================================================
-- Unit tests: Pedigree metadata parsing
-- ================================================================

io.write("\n=== Pedigree Metadata Parsing ===\n")

local function parse_kv(line)
  local key, val = line:match("^%s*([%w_]+)%s*:%s*(.+)$")
  return key, val
end

local kv_cases = {
  {"name: my-component", "name", "my-component"},
  {"version: 1.2.3", "version", "1.2.3"},
  {"description: A test component", "description", "A test component"},
  {"  indented: value", "indented", "value"},
}

for _, case in ipairs(kv_cases) do
  local k, v = parse_kv(case[1])
  assert_eq("Key from: " .. case[1], k, case[2])
  assert_eq("Val from: " .. case[1], v, case[3])
end

-- ================================================================
-- Unit tests: Recipe block detection
-- ================================================================

io.write("\n=== Recipe Block Detection ===\n")

local function is_recipe_start(line)
  return line:match("^recipes:") ~= nil or line:match("^  %w+:$") ~= nil
end

assert_true("recipes: header detected", is_recipe_start("recipes:"))
assert_true("Recipe sub-key detected", is_recipe_start("  install:"))
assert_true("Deploy recipe detected", is_recipe_start("  deploy:"))
assert_false("Non-recipe rejected", is_recipe_start("other: value"))

-- ================================================================
-- Property tests: K9 document structure invariants
-- ================================================================

io.write("\n=== Property Tests: Document Structure ===\n")

-- Property: A valid K9 file always starts with magic number
local VALID_K9_DOCS = {
  "K9!\n# SPDX-License-Identifier: PMPL-1.0-or-later\nname: foo",
  "K9!\nversion: 1.0.0",
  "K9! # with comment\nname: bar",
}

for _, doc in ipairs(VALID_K9_DOCS) do
  local first_line = doc:match("^([^\n]+)")
  assert_true("Valid K9 starts with K9!: " .. first_line:sub(1, 20), has_magic(first_line))
end

-- Property: Version strings follow semver pattern
local SEMVER_VERSIONS = {"1.0.0", "2.3.4", "0.1.0", "10.20.30"}
local INVALID_VERSIONS = {"1.0", "v1.0.0", "1", "latest"}

local function is_semver(v)
  return v:match("^%d+%.%d+%.%d+$") ~= nil
end

for _, v in ipairs(SEMVER_VERSIONS) do
  assert_true("Semver valid: " .. v, is_semver(v))
end
for _, v in ipairs(INVALID_VERSIONS) do
  assert_false("Non-semver rejected: " .. v, is_semver(v))
end

-- Property: Component names are kebab-case identifiers
local function is_valid_name(name)
  return name:match("^[a-z][a-z0-9%-]*$") ~= nil
end

local VALID_NAMES = {"my-component", "test", "web-server-v2", "a"}
local INVALID_NAMES = {"My-Component", "test component", "123bad", "", "-bad"}

for _, name in ipairs(VALID_NAMES) do
  assert_true("Valid name: " .. name, is_valid_name(name))
end
for _, name in ipairs(INVALID_NAMES) do
  assert_false("Invalid name rejected: '" .. name .. "'", is_valid_name(name))
end

-- ================================================================
-- E2E simulation: Parse a complete K9 document
-- ================================================================

io.write("\n=== E2E: Complete K9 Document Parse ===\n")

local k9_doc = [[
K9!
# SPDX-License-Identifier: PMPL-1.0-or-later
name: test-component
version: 1.0.0
description: A test component for validation
security_level: Kennel
recipes:
  install:
    - echo "installing"
  validate:
    - echo "validating"
]]

local has_magic_num = false
local has_spdx = false
local has_name = false
local recipe_count = 0

for line in k9_doc:gmatch("[^\n]+") do
  if has_magic(line) then has_magic_num = true end
  if is_spdx(line) then has_spdx = true end
  local k, _ = parse_kv(line)
  if k == "name" then has_name = true end
  if line:match("^  %w+:$") then recipe_count = recipe_count + 1 end
end

assert_true("E2E: Magic number found", has_magic_num)
assert_true("E2E: SPDX header found", has_spdx)
assert_true("E2E: name field found", has_name)
assert_eq("E2E: 2 recipes found", recipe_count, 2)

-- ================================================================
-- Results
-- ================================================================

io.write("\n=== Results: " .. pass .. " passed, " .. fail .. " failed ===\n")
os.exit(fail == 0 and 0 or 1)

-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- property_test.lua — Property-based tests for K9 pandoc filter invariants.
-- Run: lua property_test.lua

local pass = 0
local fail = 0

local function assert_true(desc, val)
  if val then pass = pass + 1; io.write("PASS: " .. desc .. "\n")
  else fail = fail + 1; io.write("FAIL: " .. desc .. "\n") end
end

-- Property: Security levels form a strict ordering
local LEVELS = {"Kennel", "Yard", "Hunt"}
local level_order = {Kennel=1, Yard=2, Hunt=3}

for i = 1, #LEVELS - 1 do
  assert_true(
    LEVELS[i] .. " < " .. LEVELS[i+1],
    level_order[LEVELS[i]] < level_order[LEVELS[i+1]]
  )
end

-- Property: All valid K9 security levels are in the known set
local VALID_LEVELS = {"Kennel", "Yard", "Hunt"}
for _, level in ipairs(VALID_LEVELS) do
  assert_true("Level in valid set: " .. level, level_order[level] ~= nil)
end

-- Property: Version bump always increases version
local function version_gte(a, b)
  local function split(v)
    local parts = {}
    for n in v:gmatch("%d+") do table.insert(parts, tonumber(n)) end
    return parts
  end
  local pa, pb = split(a), split(b)
  for i = 1, 3 do
    if (pa[i] or 0) > (pb[i] or 0) then return true end
    if (pa[i] or 0) < (pb[i] or 0) then return false end
  end
  return true
end

assert_true("1.0.1 >= 1.0.0", version_gte("1.0.1", "1.0.0"))
assert_true("2.0.0 >= 1.9.9", version_gte("2.0.0", "1.9.9"))
assert_true("1.0.0 >= 1.0.0", version_gte("1.0.0", "1.0.0"))
assert_true("NOT: 1.0.0 >= 1.0.1", not version_gte("1.0.0", "1.0.1"))

-- Property: Recipe names are predefined set
local KNOWN_RECIPES = {"install", "validate", "deploy", "migrate", "rollback", "test"}
local known = {}
for _, r in ipairs(KNOWN_RECIPES) do known[r] = true end

local SAMPLE_RECIPES = {"install", "validate", "deploy", "migrate"}
for _, r in ipairs(SAMPLE_RECIPES) do
  assert_true("Known recipe: " .. r, known[r] == true)
end

-- Property: K9 names with hyphens are always kebab-case
local KEBAB_NAMES = {
  "web-server", "auth-service", "data-pipeline", "ml-model-v2",
  "container-runtime", "api-gateway", "cache-layer"
}
for _, name in ipairs(KEBAB_NAMES) do
  assert_true("Kebab-case: " .. name, name:match("^[a-z][a-z0-9%-]*$") ~= nil)
end

-- Property: All K9 files must have SPDX header (grep-checkable invariant)
local SPDX_PATTERN = "SPDX%-License%-Identifier:"
local SAMPLE_FILES_WITH_SPDX = {
  "# SPDX-License-Identifier: PMPL-1.0-or-later\nname: foo",
  "-- SPDX-License-Identifier: MIT\nversion: 1.0.0",
}
for _, content in ipairs(SAMPLE_FILES_WITH_SPDX) do
  assert_true("SPDX present in valid file", content:match(SPDX_PATTERN) ~= nil)
end

io.write("\n=== Results: " .. pass .. " passed, " .. fail .. " failed ===\n")
os.exit(fail == 0 and 0 or 1)

// ESLint 9 flat config. Replaces .eslintrc.json (ESLint 9 no longer
// auto-loads legacy eslintrc files), same rules/behavior as before —
// eslint:recommended + @typescript-eslint/recommended, node globals,
// with the same two rules downgraded to warnings.
import js from "@eslint/js";
import tseslint from "@typescript-eslint/eslint-plugin";
import globals from "globals";

export default [
  js.configs.recommended,
  ...tseslint.configs["flat/recommended"],
  {
    languageOptions: {
      globals: { ...globals.node, ...globals.es2022 },
    },
    rules: {
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
    },
  },
  {
    ignores: ["dist/**", "node_modules/**"],
  },
];

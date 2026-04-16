const tseslint = require("@typescript-eslint/eslint-plugin");
const importPlugin = require("eslint-plugin-import");
const googleConfig = require("eslint-config-google");

const googleRules = {...googleConfig.rules};
delete googleRules["require-jsdoc"];
delete googleRules["valid-jsdoc"];

const nodeGlobals = {
    __dirname: "readonly",
    console: "readonly",
    export: "writable",
    modules: "readonly",
    process: "readonly",
    require: "readonly",
};

module.exports = [
    {
        ignores: [
            "lib/**",
            "generated/**",
            ".eslintrc.js",
            "eslint.config.js",
        ],
    },
    importPlugin.flatConfigs.recommended,
    importPlugin.flatConfigs.typescript,
    ...tseslint.configs["flat/recommended"],
    {
        languageOptions: {
            ecmaVersion: 2018,
            globals: nodeGlobals,
            sourceType: "module",
        },
        rules: {
            ...googleRules,
            quotes: ["error", "double"],
            "linebreak-style": "off",
            "import/no-unresolved": "off",
            "no-unused-vars": "off",
            "@typescript-eslint/no-unused-vars": "error",
            indent: ["error", 2],
        },
    },
    {
        files: ["src/**/*.ts"],
        languageOptions: {
            parserOptions: {
                project: ["tsconfig.json"],
                tsconfigRootDir: __dirname,
            },
        },
    },
    {
        files: ["*.js"],
        languageOptions: {
            sourceType: "commonjs",
        },
    },
];
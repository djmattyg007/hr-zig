local maintainers = [
  "Matthew Gamble <git@matthewgamble.net>",
];
local license = "Unlicense";
local homepage = "https://github.com/djmattyg007/hr-zig";
local description = "Print separator lines to your terminal en masse";

local arch_list = ["x86_64", "aarch64"];
local os_list = ["linux", "windows", "macos"];

local build = {
  builder: "zig",
  binary: "hr",
  flags: ["-Doptimize=ReleaseSmall"],
  targets: ["%s-%s" % [arch, os] for os in os_list for arch in arch_list],
};

local archive = {
  formats: ["tar.gz"],
  // This name template makes the OS and Arch compatible with the output of 'uname'.
  name_template: @'{{ .ProjectName }}_{{ title .Os }}_{{ if eq .Arch "amd64" }}x86_64{{ else if eq .Arch "386" }}i386{{ else }}{{ .Arch }}{{ end }}',
  // Use zip for Windows archives
  format_overrides: [
    { goos: "windows", formats: ["zip"] },
  ],
};

local checksum = {
  name_template: "checksums.txt",
};

local sbom(syft_cmd = "syft") = {
  artifacts: "archive",
  disable: false,
  cmd: syft_cmd,
};

local sign = {
  artifacts: "all",
  output: true,
};

local aur = {
  name: "hr-zig-bin",
  maintainers: maintainers,
  license: license,
  homepage: homepage,
  description: description,
  private_key: "{{ .Env.AUR_SSH_PRIVATE_KEY }}",
  provides: ["hr", "hr-zig"],
  conflicts: ["hr", "hr-zig"],
};

function(syft_cmd = "syft") {
  version: 2,
  project_name: "hr-zig",
  builds: [build],
  archives: [archive],
  checksum: checksum,
  sboms: [sbom(syft_cmd)],
  signs: [sign],
  aurs: [aur],
}

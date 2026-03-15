#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import sys


@dataclass(frozen=True)
class Sketch:
    name: str
    entry_file: str
    bundled_assets: tuple[str, ...] = ()
    repo_docs: tuple[str, ...] = ()
    libraries: tuple[str, ...] = ()
    external_inputs: tuple[str, ...] = ()
    notes: tuple[str, ...] = ()


SKETCHES = (
    Sketch(
        name="ChannelShiftGlitch",
        entry_file="ChannelShiftGlitch.pde",
        repo_docs=("README.md",),
        external_inputs=("data/MyImage.jpg",),
        notes=(
            "User-supplied still image required unless you change imgFileName/fileType.",
        ),
    ),
    Sketch(
        name="GlitchSort_v01b10",
        entry_file="GlitchSort_v01b10.pde",
        repo_docs=("README.md", "gs10b8_Manual_web.pdf"),
        libraries=("ControlP5", "Minim"),
        notes=("Opens images through its own file picker at runtime.",),
    ),
    Sketch(
        name="Transform_Landscape",
        entry_file="Transform_Landscape.pde",
        bundled_assets=("data/nasa-iceberg.jpg",),
        repo_docs=("README.md",),
    ),
    Sketch(
        name="Transform_SlitScan",
        entry_file="Transform_SlitScan.pde",
        bundled_assets=("data/station.mov",),
        repo_docs=("README.md",),
        libraries=("processing.video",),
    ),
    Sketch(
        name="UnifiedGlitchLab",
        entry_file="UnifiedGlitchLab.pde",
        repo_docs=("README.md",),
        libraries=("processing.video",),
        notes=(
            "Runs without media files by using a generated source.",
            "Optional inputs: data/source.jpg and data/source.mov.",
        ),
    ),
    Sketch(
        name="noise_glitch",
        entry_file="noise_glitch.pde",
        bundled_assets=("data/smallsnarl.jpg",),
        repo_docs=("README.md",),
    ),
    Sketch(
        name="video_glitch",
        entry_file="video_glitch.pde",
        repo_docs=("README.md",),
        libraries=("processing.video",),
        external_inputs=("data/bath.mov",),
        notes=("User-supplied movie required unless you change the filename in code.",),
    ),
    Sketch(
        name="webcam_glitch",
        entry_file="webcam_glitch.pde",
        repo_docs=("README.md",),
        libraries=("processing.video",),
        notes=("Requires a camera device available to Processing.",),
    ),
)

ROOT_DOCS = (
    "README.md",
    "docs/processing-setup.md",
)


@dataclass
class Report:
    errors: list[str] = field(default_factory=list)
    infos: list[str] = field(default_factory=list)


def check_path(path: Path, label: str, report: Report) -> None:
    if not path.exists():
        report.errors.append(f"Missing {label}: {path.relative_to(ROOT)}")


def validate_sketch(sketch: Sketch, report: Report) -> None:
    sketch_dir = ROOT / sketch.name
    if not sketch_dir.exists():
        report.errors.append(f"Missing sketch directory: {sketch.name}")
        return

    check_path(sketch_dir / sketch.entry_file, f"entry file for {sketch.name}", report)
    for relative_path in sketch.bundled_assets:
        check_path(sketch_dir / relative_path, f"bundled asset for {sketch.name}", report)
    for relative_path in sketch.repo_docs:
        check_path(sketch_dir / relative_path, f"documentation for {sketch.name}", report)

    if sketch.libraries:
        report.infos.append(
            f"{sketch.name}: Processing libraries required: {', '.join(sketch.libraries)}"
        )

    for relative_path in sketch.external_inputs:
        asset_path = sketch_dir / relative_path
        if asset_path.exists():
            report.infos.append(f"{sketch.name}: found user media at {asset_path.relative_to(ROOT)}")
        else:
            report.infos.append(
                f"{sketch.name}: user media not bundled; add {asset_path.relative_to(ROOT)}"
            )

    for note in sketch.notes:
        report.infos.append(f"{sketch.name}: {note}")


def print_section(title: str, lines: list[str]) -> None:
    if not lines:
        return
    print(title)
    for line in lines:
        print(f"- {line}")


def main() -> int:
    report = Report()

    for relative_path in ROOT_DOCS:
        check_path(ROOT / relative_path, "root documentation", report)

    for sketch in SKETCHES:
        validate_sketch(sketch, report)

    print(f"Validated {len(SKETCHES)} sketches in {ROOT.name}.")
    print_section("Info", report.infos)
    print_section("Errors", report.errors)

    if report.errors:
        print(f"\nValidation failed with {len(report.errors)} error(s).")
        return 1

    print("\nValidation passed.")
    return 0


ROOT = Path(__file__).resolve().parent.parent


if __name__ == "__main__":
    sys.exit(main())

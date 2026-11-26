"""Generates the architecture diagrams as SVG.

Style: white background, Google Sans Flex and Google Sans Code, light group
panels, white cards with a colored accent bar, and right-angle arrows with
small pill labels.

Usage: python3 generate.py <out-dir>
"""
import sys
from html import escape
from pathlib import Path

OUT = Path(sys.argv[1])

# Flutter blues for the app layers, Google colors for the data side.
FLUTTER = "#0175C2"
FLUTTER_DARK = "#02569B"
GOOGLE_BLUE = "#1A73E8"
GREEN = "#188038"
YELLOW = "#E37400"
GRAY = "#5F6368"
INK = "#1B1B1F"
LINE = "#E3E3E6"
SURF = "#F7F8F9"

SANS = "'Google Sans Flex', 'Google Sans', Arial, sans-serif"
MONO = "'Google Sans Code', ui-monospace, monospace"


class Svg:
    def __init__(self, w, h, title):
        self.w, self.h, self.title = w, h, title
        self.parts = []

    def group(self, x, y, w, h, label, color):
        self.parts.append(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="20" '
            f'fill="{SURF}" stroke="{LINE}" stroke-width="1.5"/>'
            f'<text x="{x + 22}" y="{y + 32}" font-family="{SANS}" font-size="13" '
            f'font-weight="600" letter-spacing="1.2" fill="{color}">{label}</text>'
        )

    def card(self, x, y, w, h, title, sub, color, code=None):
        p = self.parts
        # Shrink long titles so they stay inside the card.
        size = min(18, round((w - 40) / (len(title) * 0.56), 1))
        p.append(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="12" fill="#fff" '
            f'stroke="{LINE}" stroke-width="1.5"/>'
            f'<rect x="{x}" y="{y + 10}" width="5" height="{h - 20}" rx="2.5" fill="{color}"/>'
            f'<text x="{x + 22}" y="{y + 34}" font-family="{SANS}" font-size="{size}" '
            f'font-weight="600" fill="{INK}">{escape(title)}</text>'
            f'<text x="{x + 22}" y="{y + 57}" font-family="{SANS}" font-size="14" '
            f'fill="{GRAY}">{escape(sub)}</text>'
        )
        if code:
            p.append(
                f'<text x="{x + 22}" y="{y + 82}" font-family="{MONO}" font-size="13" '
                f'fill="{GRAY}">{escape(code)}</text>'
            )

    def arrow(self, pts, color=GRAY, dashed=False, label=None, at=None):
        d = "M" + " L".join(f"{x} {y}" for x, y in pts)
        dash = ' stroke-dasharray="6 5"' if dashed else ""
        mid = color.lstrip("#")
        self.parts.append(
            f'<path d="{d}" fill="none" stroke="{color}" stroke-width="2"{dash} '
            f'marker-end="url(#a{mid})"/>'
        )
        self.markers = getattr(self, "markers", set()) | {color}
        if label:
            lx, ly = at
            tw = len(label) * 7.2 + 20
            self.parts.append(
                f'<rect x="{lx - tw / 2}" y="{ly - 12}" width="{tw}" height="24" rx="12" '
                f'fill="#fff" stroke="{color}" stroke-opacity=".35"/>'
                f'<text x="{lx}" y="{ly + 4.5}" text-anchor="middle" font-family="{SANS}" '
                f'font-size="12.5" font-weight="500" fill="{color}">{label}</text>'
            )

    def save(self, name):
        markers = "".join(
            f'<marker id="a{c.lstrip("#")}" viewBox="0 0 10 10" refX="9" refY="5" '
            f'markerWidth="7" markerHeight="7" orient="auto-start-reverse">'
            f'<path d="M0 0 L10 5 L0 10 z" fill="{c}"/></marker>'
            for c in sorted(getattr(self, "markers", set()))
        )
        svg = (
            f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {self.w} {self.h}" '
            f'width="{self.w}" height="{self.h}" role="img" aria-label="{self.title}">'
            f'<title>{self.title}</title><defs>{markers}</defs>'
            f'<rect width="{self.w}" height="{self.h}" fill="#fff"/>'
            + "".join(self.parts)
            + "</svg>"
        )
        (OUT / f"{name}.svg").write_text(svg)


# Five columns. Each panel is 330 wide with a 40 gap, so long class names fit.
PX = [20, 390, 760, 1130, 1500]
PW, GAP = 330, 40
CW = PW - 40          # card width
TOP, LOW = 96, 286    # y of the top and bottom card rows
PANEL_Y, PANEL_H = 30, 360
W, H = PX[-1] + PW + 20, PANEL_Y + PANEL_H + 70


def cx(col):
    """Left x of a card in a column."""
    return PX[col] + 20


def gap_mid(col):
    """Center x of the gap to the right of a column."""
    return PX[col] + PW + GAP / 2


def note(s, text, x, y, color=GRAY, anchor="middle", size=12.5):
    s.parts.append(
        f'<text x="{x}" y="{y}" text-anchor="{anchor}" font-family="{SANS}" '
        f'font-size="{size}" fill="{color}">{escape(text)}</text>'
    )


def frame(s, labels):
    colors = [FLUTTER, FLUTTER_DARK, GOOGLE_BLUE, GREEN, YELLOW]
    for x, label, color in zip(PX, labels, colors):
        s.group(x, PANEL_Y, PW, PANEL_H, label, color)


def wires(s, top_h, view_to_state_label, footer, calls_label="calls"):
    """The arrows shared by every diagram. top_h is the height of the top cards."""
    mid = TOP + 36
    # View builds the tile.
    s.arrow([(cx(0) + CW / 2, TOP + top_h), (cx(0) + CW / 2, LOW)], FLUTTER,
            label="builds", at=(cx(0) + CW / 2, (TOP + top_h + LOW) / 2))
    # View calls state, state notifies view.
    x0, x1 = cx(0) + CW, cx(1)
    s.arrow([(x0, mid - 12), (x1, mid - 12)], FLUTTER_DARK)
    s.arrow([(x1, mid + 12), (x0, mid + 12)], FLUTTER_DARK, dashed=True)
    note(s, calls_label, gap_mid(0), mid - 20, FLUTTER_DARK, size=12)
    note(s, view_to_state_label, gap_mid(0), mid + 32, FLUTTER_DARK, size=12)
    # State asks the repository.
    s.arrow([(cx(1) + CW, mid), (cx(2), mid)], GOOGLE_BLUE)
    # Repository fetches remote and caches locally.
    s.arrow([(cx(2) + CW, mid), (cx(3), mid)], GREEN)
    note(s, "fetch", gap_mid(2), mid - 10, GREEN, size=12)
    rx = cx(2) + CW / 2
    s.arrow([(rx, TOP + top_h), (rx, LOW + 36), (cx(3), LOW + 36)], GREEN,
            label="cache", at=(rx + (cx(3) - rx) / 2 + 10, LOW + 36))
    # Data stores talk to their sources.
    s.arrow([(cx(3) + CW, mid), (cx(4), mid)], YELLOW)
    s.arrow([(cx(3) + CW, LOW + 36), (cx(4), LOW + 36)], YELLOW)
    note(s, footer, PX[0] + 4, PANEL_Y + PANEL_H + 42, anchor="start", size=15)


def layered():
    s = Svg(W, H, "Layered architecture")
    frame(s, ["PRESENTATION", "STATE", "DOMAIN", "DATA", "SOURCES"])
    s.card(cx(0), TOP, CW, 72, "Views", "Pages that show the state", FLUTTER)
    s.card(cx(0), LOW, CW, 72, "Widgets", "Reusable pieces of UI", FLUTTER)
    s.card(cx(1), TOP, CW, 72, "Store or Notifier", "Holds state, runs actions", FLUTTER_DARK)
    s.card(cx(2), TOP, CW, 72, "Repository", "Single source of truth", GOOGLE_BLUE)
    s.card(cx(3), TOP, CW, 72, "Remote store", "REST or GraphQL", GREEN)
    s.card(cx(3), LOW, CW, 72, "Local store", "Hive cache on device", GREEN)
    s.card(cx(4), TOP, CW, 72, "Rick and Morty API", "rickandmortyapi.com", YELLOW)
    s.card(cx(4), LOW, CW, 72, "Device storage", "A Hive box", YELLOW)
    wires(s, 72, "updates",
          "Each layer only calls the next one. Views never call the network.")
    s.save("layered")


def state_diagram(name, title, state_title, state_sub, state_code,
                  view_sub, view_code, remote_title, remote_sub, source_sub, footer,
                  calls_label="calls"):
    s = Svg(W, H, title)
    frame(s, ["VIEW", "STATE", "DOMAIN", "DATA", "SOURCES"])
    s.card(cx(0), TOP, CW, 96, "CharactersPage", view_sub, FLUTTER, code=view_code)
    s.card(cx(0), LOW, CW, 72, "CharacterTile", "One row in the list", FLUTTER)
    s.card(cx(1), TOP, CW, 96, state_title, state_sub, FLUTTER_DARK, code=state_code)
    s.card(cx(2), TOP, CW, 96, "CharactersRepository", "Cache first, then network",
           GOOGLE_BLUE, code="getCharacters()")
    s.card(cx(3), TOP, CW, 72, remote_title, remote_sub, GREEN)
    s.card(cx(3), LOW, CW, 72, "HiveCharactersLocalStore", "Saves the list as JSON", GREEN)
    s.card(cx(4), TOP, CW, 72, "Rick and Morty API", source_sub, YELLOW)
    s.card(cx(4), LOW, CW, 72, "Hive box", "On the device", YELLOW)
    wires(s, 96, "rebuilds", footer, calls_label)
    s.save(name)


layered()
state_diagram(
    "mobx", "MobX with REST",
    "CharactersStore", "@observable state", "load({forceRefresh})",
    "Wrapped in an Observer", "Observer(builder: ...)",
    "RestCharactersRemoteStore", "GET /api/character", "REST",
    "main.dart creates each layer and passes it into the next one.",
)
state_diagram(
    "mobx_graphql", "MobX with GraphQL",
    "CharactersStore", "@observable state", "load({forceRefresh})",
    "Wrapped in an Observer", "Observer(builder: ...)",
    "GraphQLCharactersRemoteStore", "query Characters", "GraphQL",
    "Same as the MobX REST example. Only the remote store changes.",
)
state_diagram(
    "riverpod", "Riverpod with REST",
    "CharactersNotifier", "AsyncNotifier", "AsyncValue<List<Character>>",
    "A ConsumerWidget", "ref.watch(charactersProvider)",
    "RestCharactersRemoteStore", "GET /api/character", "REST",
    "Providers create each layer. Tests swap the repository with one override.",
)
state_diagram(
    "bloc_cubit", "Bloc: Cubit",
    "CharactersCubit", "Plain methods, no events", "load({forceRefresh})",
    "BlocBuilder rebuilds on change", "BlocBuilder<CharactersCubit, ...>",
    "RestCharactersRemoteStore", "GET /api/character", "REST",
    "RepositoryProvider shares the repository. BlocProvider creates the cubit on the page.",
)
state_diagram(
    "bloc", "Bloc: events",
    "CharactersBloc", "Events in, sealed states out", "on<CharactersSearchChanged>",
    "Adds events, switches on state", "bloc.add(CharactersRefreshed())",
    "RestCharactersRemoteStore", "GET /api/character?name=", "REST",
    "Search is debounced and restartable. Only the newest load changes the screen.",
    calls_label="events",
)


def bloc_advanced():
    s = Svg(W, H, "Bloc for bigger teams")
    frame(s, ["APP · VIEW", "APP · STATE", "REPOSITORY PACKAGE", "DATA", "SOURCES"])
    s.card(cx(0), TOP, CW, 96, "CharactersPage", "BlocProvider, then the view", FLUTTER,
           code="CharactersView")
    s.card(cx(0), LOW, CW, 72, "CharacterTile", "One row in the list", FLUTTER)
    s.card(cx(1), TOP, CW, 96, "CharactersBloc", "Status enum state, Equatable", FLUTTER_DARK,
           code="on<CharactersSearchChanged>")
    s.card(cx(2), TOP, CW, 96, "CharactersRepository", "packages/characters_repository",
           GOOGLE_BLUE, code="Character, CharactersCache")
    s.card(cx(3), TOP, CW, 72, "RickAndMortyApiClient", "packages/rick_and_morty_api", GREEN)
    s.card(cx(3), LOW, CW, 72, "HiveCharactersCache", "In the app, implements the cache", GREEN)
    s.card(cx(4), TOP, CW, 72, "Rick and Morty API", "REST", YELLOW)
    s.card(cx(4), LOW, CW, 72, "Hive box", "On the device", YELLOW)
    wires(s, 96, "rebuilds",
          "Each package has its own models and tests. ApiCharacter becomes Character in the repository.",
          calls_label="events")
    s.save("bloc_advanced")


bloc_advanced()
print("ok")

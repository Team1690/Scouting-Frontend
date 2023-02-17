import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:scouting_frontend/models/map_nullable.dart";
import "package:scouting_frontend/models/team_model.dart";

class TeamsSearchBox extends StatefulWidget {
  TeamsSearchBox({
    required this.buildSuggestion,
    required this.teams,
    required this.buildWithTeam,
    this.dontValidate = false,
    this.buildWithoutTeam,
    this.onSelected,
    this.initalTeam,
    this.onOutsideChange,
  });
  final void Function(LightTeam)? onOutsideChange;
  final LightTeam? initalTeam;
  final Widget Function(Widget searchBox, void Function() resetSearchbox)?
      buildWithoutTeam;
  final String Function(LightTeam) buildSuggestion;
  final void Function(LightTeam)? onSelected;
  final bool dontValidate;
  final List<LightTeam> teams;
  final Widget Function(
    BuildContext,
    LightTeam,
    Widget searchBox,
    void Function() resetSearchbox,
  ) buildWithTeam;

  @override
  State<TeamsSearchBox> createState() => _TeamsSearchBoxState();
}

class _TeamsSearchBoxState extends State<TeamsSearchBox> {
  TextEditingController typeAheadController = TextEditingController();
  LightTeam? team;

  Widget searchBox() => SearchBox(
        buildSuggestion: widget.buildSuggestion,
        buildWithTeam: widget.buildWithTeam,
        dontValidate: widget.dontValidate,
        setTeam: (final LightTeam team) {
          if (mounted) {
            widget.onSelected.mapNullable(
              (final void Function(LightTeam) onSelected) => onSelected(team),
            );
            setState(() {
              this.team = team;
            });
          }
        },
        teams: widget.teams,
        typeAheadController: typeAheadController,
      );

  void reset() => setState(() {
        team = null;
        typeAheadController.clear();
      });

  @override
  Widget build(final BuildContext context) =>
      team.mapNullable(
        (final LightTeam team) =>
            widget.buildWithTeam(context, team, searchBox(), reset),
      ) ??
      widget.initalTeam.mapNullable((final LightTeam team) {
        typeAheadController.text = "${team.number} ${team.name}";
        return widget.buildWithTeam(context, team, searchBox(), reset);
      }) ??
      widget.buildWithoutTeam.mapNullable(
        (final Widget Function(Widget, void Function()) buildWithoutTeam) =>
            buildWithoutTeam(searchBox(), reset),
      ) ??
      searchBox();
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    required this.buildSuggestion,
    required this.buildWithTeam,
    required this.dontValidate,
    required this.setTeam,
    required this.teams,
    required this.typeAheadController,
  });
  final String Function(LightTeam) buildSuggestion;
  final bool dontValidate;
  final List<LightTeam> teams;
  final Widget Function(
    BuildContext,
    LightTeam,
    Widget searchBox,
    void Function() resetSearchbox,
  ) buildWithTeam;
  final TextEditingController typeAheadController;
  final void Function(LightTeam) setTeam;

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: TypeAheadFormField<LightTeam>(
        validator: (final String? selectedTeam) {
          if (dontValidate) {
            return null;
          }
          if (selectedTeam == "") {
            return "Please pick a team";
          }
          return null;
        },
        textFieldConfiguration: TextFieldConfiguration(
          onSubmitted: (final String number) {
            try {
              final LightTeam team = teams.firstWhere(
                (final LightTeam team) => team.number.toString() == number,
              );
              typeAheadController.text = buildSuggestion(team);
            } on StateError catch (_) {
              //ignored
            }
          },
          onTap: typeAheadController.clear,
          controller: typeAheadController,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            hintText: "Search Team",
          ),
        ),
        suggestionsCallback: (final String pattern) => teams.where(
          (final LightTeam team) {
            return team.number.toString().startsWith(pattern);
          },
        ).toList()
          ..sort(
            (final LightTeam firstTeam, final LightTeam secondTeam) =>
                firstTeam.number.compareTo(secondTeam.number),
          ),
        itemBuilder: (final BuildContext context, final LightTeam team) {
          return buildSuggestion(team).isNotEmpty
              ? ListTile(title: Text(buildSuggestion(team)))
              : Container();
        },
        transitionBuilder: (
          final BuildContext context,
          final Widget suggestionsBox,
          final AnimationController? controller,
        ) {
          return FadeTransition(
            child: suggestionsBox,
            opacity: CurvedAnimation(
              parent: controller!,
              curve: Curves.fastOutSlowIn,
            ),
          );
        },
        noItemsFoundBuilder: (final BuildContext context) => Container(
          height: 60,
          child: Center(
            child: Text(
              "No Teams Found",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        hideSuggestionsOnKeyboardHide: false,
        onSuggestionSelected: (final LightTeam team) {
          typeAheadController.text = buildSuggestion(team);
          setTeam(team);
        },
      ),
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';

class ExpandableCard extends StatefulWidget {
  const ExpandableCard(
      {Key? key,
      this.backgroundColor,
      required this.header,
      required this.child,
      this.trailingActions})
      : super(key: key);

  final Widget header;
  final Widget child;
  final List<Widget>? trailingActions;
  final Color? backgroundColor;

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with AutomaticKeepAliveClientMixin<ExpandableCard> {
  bool isOpen = false;

  final GlobalKey expanderKey = GlobalKey<ExpanderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = FluentTheme.of(context);

    return Column(children: [
      Expander(
          key: expanderKey,
          headerShape: (open) => const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
          onStateChanged: (state) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (mounted) setState(() => isOpen = state);
            });
          },
          trailing: isOpen && widget.trailingActions != null
              ? Container(
                  height: 31,
                  constraints: const BoxConstraints(minWidth: 75),
                  child: Row(
                    children: widget.trailingActions!,
                  ),
                )
              : null,
          header: widget.header,
          content: widget.child),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}

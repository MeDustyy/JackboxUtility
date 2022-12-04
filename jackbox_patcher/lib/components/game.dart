import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:palette_generator/palette_generator.dart';

import '../model/usermodel/userjackboxgame.dart';
import '../model/usermodel/userjackboxpack.dart';
import '../services/api/api_service.dart';

class GameCard extends StatefulWidget {
  GameCard({Key? key, required this.pack, required this.game})
      : super(key: key);

  final UserJackboxPack pack;
  final UserJackboxGame game;
  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  Color? backgroundColor;
  int downloadingProgress = 0;
  String status = "";
  double progression = 0;
  String substatus = "";

  @override
  void initState() {
    _loadBackgroundColor();
    super.initState();
  }

  void _loadBackgroundColor() {
    PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(
            APIService().assetLink(widget.pack.pack.background)))
        .then((value) {
      setState(() {
        backgroundColor = value.dominantColor?.color;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
            margin: EdgeInsets.only(top: 30, left: 5),
            child: Container(
                width: 20,
                height: 20,
                decoration: new BoxDecoration(
                  color: widget.game.getInstalledStatus(widget.pack.path).color,
                  shape: BoxShape.circle,
                ))),
        Container(
            height: 200,
            margin: EdgeInsets.only(top: 25),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Acrylic(
                    shadowColor: backgroundColor,
                    blurAmount: 1,
                    tintAlpha: 1,
                    tint: Color.fromARGB(255, 48, 48, 48),
                    child: Container(
                        padding: EdgeInsets.only(bottom: 12),
                        margin: EdgeInsets.only(top: 50),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Column(children: [
                                  Text(widget.game.game.name,
                                      style: TextStyle(fontSize: 25)),
                                  SizedBox(height: 10),
                                  Text(
                                    widget.game.game.description,
                                  ),
                                  Expanded(child: SizedBox()),
                                  Row(children: [
                                    Expanded(
                                        child: Button(
                                            onPressed: () {
                                              _installPatchDialog();
                                            },
                                            child: Text("Installer")))
                                  ])
                                ]),
                              ))
                            ]))))),
        SizedBox(
            height: 75,
            child: Padding(
                padding: EdgeInsets.all(8),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl:
                            APIService().assetLink(widget.game.game.background),
                        fit: BoxFit.contain,
                      ))
                ]))),
        Container(
            margin: EdgeInsets.only(top: 35, left: 10),
            child: Flyout(
                openMode: FlyoutOpenMode.hover,
                content: (context) => FlyoutContent(
                    child: Text(
                        widget.game.getInstalledStatus(widget.pack.path).info)),
                child: Container(
                    width: 10,
                    height: 10,
                    decoration: new BoxDecoration(
                      color: widget.game
                          .getInstalledStatus(widget.pack.path)
                          .color,
                      shape: BoxShape.circle,
                    )))),
      ],
    ));
  }

  void _installPatchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return downloadingProgress == 0
              ? ContentDialog(
                  title: Text("Installation du patch"),
                  content: Text(
                      "Vous allez installer le patch. Cette action est irréversible."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () async {
                        downloadingProgress = 1;
                        setState(() {});
                        await widget.game.downloadPatch(widget.pack.path!,
                            (String stat, String substat, double progress) {
                          status = stat;
                          substatus = substat;
                          progression = progress;
                          setState(() {});
                        });
                        downloadingProgress = 2;
                        setState(() {});
                      },
                      child: Text("Continuer"),
                    ),
                  ],
                )
              : (downloadingProgress == 1
                  ? buildDownloadingPatchDialog(status, substatus, progression)
                  : buildFinishDialog());
        });
      },
    );
  }

  ContentDialog buildDownloadingPatchDialog(
      String status, String substatus, double progression) {
    return ContentDialog(
      title: Text("Installation du patch"),
      content: SizedBox(
          height: 200,
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                ProgressRing(value: progression),
                SizedBox(height: 10),
                Text(status, style: TextStyle(fontSize: 20)),
                Text(substatus, style: TextStyle(fontSize: 16)),
              ]))),
    );
  }

  ContentDialog buildFinishDialog() {
    return ContentDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            downloadingProgress = 0;
            setState(() {});
          },
          child: Text("Fermer"),
        ),
      ],
      title: Text("Installation du patch"),
      content: SizedBox(
          height: 200,
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Icon(FluentIcons.check_mark),
                SizedBox(height: 10),
                Text("Installation terminée", style: TextStyle(fontSize: 20)),
                Text("Vous pouvez fermer cette pop-up",
                    style: TextStyle(fontSize: 16)),
              ]))),
    );
  }
}

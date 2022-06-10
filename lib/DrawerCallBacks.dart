
abstract class DrawerCallBacks {
  void onTileTapped(List sessionTitles, String title, List? sessions, int index, int selectedSessionIndex);
  void onSubTileTapped(List sessionTitles, String title, List? sessions, int index, int selectedSessionIndex, int selectedSubSessionIndex);
  void onSimpleTileTapped(String title);
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:sp_client/bloc/blocs.dart';
import 'package:sp_client/model/models.dart';
import 'package:sp_client/util/utils.dart';
import 'package:sp_client/widget/sort_dialog.dart';

class MainAppBar extends StatelessWidget with PreferredSizeWidget {
  final PreferredSizeWidget bottom;

  @override
  final Size preferredSize;

  MainAppBar({
    Key key,
    this.bottom,
  })  : preferredSize = Size.fromHeight(
            kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var drawerBloc = BlocProvider.of<MainDrawerBloc>(context);
    var listBloc = BlocProvider.of<ListBloc>(context);

    return BlocListener<FolderBloc, FolderState>(
      listener: (context, folderState) {
        if (folderState is FoldersLoaded && folderState.folders.isEmpty) {
          drawerBloc.dispatch(SelectMenu(0));
        }
      },
      child: BlocBuilder<FolderBloc, FolderState>(
        builder: (context, folderState) {
          return BlocBuilder<MainDrawerBloc, MainDrawerState>(
            builder: (context, drawerState) {
              return BlocBuilder<ListBloc, ListState>(
                builder: (context, memoListState) {
                  var title;
                  if (memoListState is UnSelectableList) {
                    if (drawerState.selectedMenu == 0) {
                      title = AppLocalizations.of(context).actionNotes;
                    } else {
                      if (drawerState.folderId != null) {
                        if (drawerState.folderId == Folder.defaultId) {
                          title = AppLocalizations.of(context).folderDefault;
                        } else if (folderState is FoldersLoaded) {
                          var folders = folderState.folders;
                          var findFolder = folders.firstWhere(
                              (folder) => folder.id == drawerState.folderId);
                          title = findFolder?.name ??
                              AppLocalizations.of(context).actionFolder;
                        }
                      } else {
                        title = AppLocalizations.of(context).actionFolder;
                      }
                    }
                  } else {
                    title = (memoListState as SelectableList)
                        .selectedItemCount
                        .toString();
                  }

                  return AppBar(
                    bottom: bottom,
                    leading: (memoListState is UnSelectableList
                        ? null
                        : IconButton(
                            icon: Icon(
                              Icons.close,
                            ),
                            onPressed: () {
                              listBloc.dispatch(UnSelectable());
                            },
                          )),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: (memoListState is UnSelectableList
                        ? null
                        : Theme.of(context).accentColor),
                    elevation: memoListState is SelectableList ? 4.0 : 0.0,
                    actions: (memoListState is UnSelectableList
                        ? _buildNotesActions(context)
                        : _buildSelectableActions(context)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildNotesActions(BuildContext context) {
    var listBloc = BlocProvider.of<ListBloc>(context);
    var memoSort = Provider.of<MemoSort>(context);
    return [
      IconButton(
        icon: Icon(Icons.sort),
        tooltip: AppLocalizations.of(context).actionSort,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => ChangeNotifierProvider<MemoSort>.value(
            value: memoSort,
            child: SortDialog(),
          ),
        ),
      ),
      IconButton(
        icon: Icon(OMIcons.edit),
        tooltip: AppLocalizations.of(context).actionEdit,
        onPressed: () {
          listBloc.dispatch(Selectable());
        },
      ),
    ];
  }

  List<Widget> _buildSelectableActions(BuildContext context) {
    var memoBloc = BlocProvider.of<MemoBloc>(context);
    var listBloc = BlocProvider.of<ListBloc>(context);
    var memoListState = listBloc.currentState as SelectableList;
    var selectedItems = memoListState.selectedItems;
    return [
      if (selectedItems.length > 1)
        IconButton(
          icon: Icon(Icons.merge_type),
          onPressed: () {
            var selectedMemo = List.castFrom<dynamic, Memo>(selectedItems);
            memoBloc.dispatch(MergeMemo(selectedMemo));
            listBloc.dispatch(UnSelectable());
          },
        ),
      IconButton(
        icon: Icon(OMIcons.delete),
        tooltip: AppLocalizations.of(context).actionDelete,
        onPressed: () {
          selectedItems.forEach((item) {
            memoBloc.dispatch(DeleteMemo(item));
          });
          listBloc.dispatch(UnSelectable());
        },
      ),
    ];
  }
}

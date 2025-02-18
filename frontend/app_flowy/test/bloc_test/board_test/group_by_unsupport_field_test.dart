import 'package:app_flowy/plugins/board/application/board_bloc.dart';
import 'package:app_flowy/plugins/grid/application/field/field_editor_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flowy_sdk/protobuf/flowy-grid/field_entities.pb.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

void main() {
  late AppFlowyBoardTest boardTest;
  late FieldEditorBloc editorBloc;
  late BoardTestContext context;

  setUpAll(() async {
    boardTest = await AppFlowyBoardTest.ensureInitialized();
    context = await boardTest.createTestBoard();
    final fieldContext = context.singleSelectFieldContext();
    editorBloc = context.createFieldEditor(
      fieldContext: fieldContext,
    )..add(const FieldEditorEvent.initial());

    await boardResponseFuture();
  });

  group('Group with not support grouping field:', () {
    blocTest<FieldEditorBloc, FieldEditorState>(
      "switch to text field",
      build: () => editorBloc,
      wait: boardResponseDuration(),
      act: (bloc) async {
        bloc.add(const FieldEditorEvent.switchToField(FieldType.RichText));
      },
      verify: (bloc) {
        bloc.state.field.fold(
          () => throw Exception(),
          (field) => field.fieldType == FieldType.RichText,
        );
      },
    );
    blocTest<BoardBloc, BoardState>(
      'assert the number of groups is 1',
      build: () =>
          BoardBloc(view: context.gridView)..add(const BoardEvent.initial()),
      wait: boardResponseDuration(),
      verify: (bloc) {
        assert(bloc.groupControllers.values.length == 1,
            "Expected 1, but receive ${bloc.groupControllers.values.length}");
      },
    );
  });
}

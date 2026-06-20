import 'package:widgetbook/widgetbook.dart';

import 'book/colors.book.dart';
import 'book/dop_back_button.book.dart';
import 'book/dop_button.book.dart';
import 'book/dop_checkbox.book.dart';
import 'book/dop_dialog.book.dart';
import 'book/dop_dropdown.book.dart';
import 'book/dop_focus_orb.book.dart';
import 'book/dop_header_widget.book.dart';
import 'book/dop_input.book.dart';
import 'book/dop_knob.book.dart';
import 'book/dop_list_tile.book.dart';
import 'book/dop_responsive_pane.book.dart';
import 'book/dop_scale_selector.book.dart';
import 'book/dop_slider.book.dart';
import 'book/dop_step_indicator.book.dart';
import 'book/dop_text.book.dart';
import 'book/icons.book.dart';

/// Widgetbook catalog for the dopamine_ui package.
///
/// Each entry lives in its own `book/*.book.dart` file next to nothing but its
/// own use cases; this list is only the final composition, so adding a widget
/// never touches existing entries.
final dopamineUiWidgetbookDirectories = <WidgetbookNode>[
  dopTextBook,
  dopButtonBook,
  dopBackButtonBook,
  dopInputBook,
  dopDialogBook,
  dopDropdownBook,
  dopCheckboxBook,
  dopHeaderWidgetBook,
  dopListTileBook,
  dopResponsivePaneBook,
  dopScaleSelectorBook,
  dopSliderBook,
  dopFocusOrbBook,
  dopKnobBook,
  dopStepIndicatorBook,
  colorsBook,
  iconsBook,
];

title: eclipse modify tab ui
date: 2015-07-09 15:43:37
tags: [eclipse]
categories: eclipse
---
### problems
+ editor的title太大
在eclipse-mars/plugins/org.eclipse.ui.themes_1.1.0.v20150511-0913/css中修改e4_default_gtk.css

    .MPartStack {
      font-size: 9;
      font-family: Liberation Sans;
      swt-tab-renderer: null;
      swt-tab-height: 22px;
      swt-selected-tabs-background: #FFFFFF #ECE9D8 100%;
      swt-simple: false;
      swt-mru-visible: false;
    }
+ 修改gtk样式

kate ~/.gtkrc-2.0

    style "gtkcompact" {
    GtkButton::default_border={0,0,0,0}
    GtkButton::default_outside_border={0,0,0,0}
    GtkButtonBox::child_min_width=0
    GtkButtonBox::child_min_heigth=0
    GtkButtonBox::child_internal_pad_x=0
    GtkButtonBox::child_internal_pad_y=0
    GtkMenu::vertical-padding=1
    GtkMenuBar::internal_padding=0
    GtkMenuItem::horizontal_padding=4
    GtkToolbar::internal-padding=0
    GtkToolbar::space-size=0
    GtkOptionMenu::indicator_size=0
    GtkOptionMenu::indicator_spacing=0
    GtkPaned::handle_size=4
    GtkRange::trough_border=0
    GtkRange::stepper_spacing=0
    GtkScale::value_spacing=0
    GtkScrolledWindow::scrollbar_spacing=0
    GtkTreeView::vertical-separator=0
    GtkTreeView::horizontal-separator=0
    GtkTreeView::fixed-height-mode=TRUE
    GtkWidget::focus_padding=0
    }
    class "GtkWidget" style "gtkcompact"

+ 插件编辑样式
[eclipse-themes][2]
+ use gtk2
export SWT_GTK3=0

### link
[http://stackoverflow.com/questions/11805784/very-large-tabs-in-eclipse-panes-on-ubuntu][4]
[http://unix.stackexchange.com/questions/25964/reduce-eclipse-tab-size-with-gtk-theming][3]
[http://stackoverflow.com/questions/3124629/how-can-i-configure-the-font-size-for-the-tree-item-in-the-package-explorer-in-e/3970100][1]
[use gtk2][5]

[1]: http://stackoverflow.com/questions/3124629/how-can-i-configure-the-font-size-for-the-tree-item-in-the-package-explorer-in-e/3970100#3970100
[2]: https://github.com/jeeeyul/eclipse-themes
[3]: http://unix.stackexchange.com/questions/25964/reduce-eclipse-tab-size-with-gtk-theming
[4]: http://stackoverflow.com/questions/11805784/very-large-tabs-in-eclipse-panes-on-ubuntu
[5]: https://coffeeorientedprogramming.wordpress.com/2014/10/27/how-to-tell-if-you-are-running-eclipse-on-gtk2-or-on-gtk3/

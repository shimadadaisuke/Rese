import $ from 'jquery';
import 'jquery-ui-dist/jquery-ui';

$(function() {
  // 管理者専用ボタンがクリックされたら、パスワード入力用のポップアップを表示する
  $("#admin-button").on("click", function(e) {
    e.preventDefault();
    $("#password-dialog").dialog("open");
  });

  // ポップアップの初期設定
  $("#password-dialog").dialog({
    autoOpen: false,
    resizable: false,
    height: "auto",
    width: 400,
    modal: true,
    buttons: {
      "キャンセル": function() {
        $(this).dialog("close");
      }
    }
  });
});

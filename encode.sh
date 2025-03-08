#!/bin/bash

# エンコード前ファイルパス
input_file_path=""

#エンコードファイル出力先フォルダパス
output_folder_path=""

# ログ出力先フォルダパス
log_output_folder_path=""

# ロックファイルのパス
file="${output_folder_path}/lockfile.lock"

# 入力ファイルパスから出力ファイル名を生成
output=${1#*/${input_file_path}/}

# ログファイルのパスを設定
logs="${log_output_folder_path}/${output}.log"

# 出力ファイルのパスを設定（.m2tsを.mp4に変換）
output="${output_folder_path}/${output%.m2ts}.mp4"

# ロックファイルの存在確認と処理の開始
while :
do

# 他の変換処理が実行中の場合は10分待機
if [ -e $file ]; then
	sleep 10m
       	continue
fi

# ロックファイルを作成
touch $file

echo "$logs"

# ログファイルに開始時刻を記録
date > "$logs"

# FFmpegによる動画変換（VAAPI使用）
sudo /usr/bin/ffmpeg -y -vaapi_device /dev/dri/renderD128 -i "$1" -vf 'format=nv12,hwupload' -c:v hevc_vaapi  -crf 28 -vsync 1 -c:a aac -profile:a aac_low -strict experimental -bsf:a aac_adtstoasc "$output" >> "$logs" 2>&1

break

done

# ロックファイルを削除
rm -f $file

# ログファイルに終了時刻を記録
date >> "$logs"

exit

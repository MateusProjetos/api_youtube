from flask import Flask, request, jsonify
import yt_dlp

app = Flask(__name__)

@app.route('/youtube_videos', methods=['POST'])
def get_youtube_videos():
    try:
        data = request.get_json()
        channel_id = data['id_do_canal']
        max_videos = int(request.args.get('max_videos', 50))

        ydl_opts = {
            'playlistend': max_videos,
            'extract_flat': True,
            'quiet': True,
            'skip_download': True,
        }

        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(f'https://www.youtube.com/channel/{channel_id}/videos', download=False)

        videos = []
        for video in info['entries']:
            try:
                videos.append({
                    'title': video.get('title', 'Título não disponível'),
                    'id': video.get('id', 'ID não disponível'),
                    'url': f"https://www.youtube.com/watch?v={video['id']}"  
                })
            except KeyError as e:
                print(f"Erro ao extrair informações do vídeo: {e}")

        return jsonify(videos)

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)

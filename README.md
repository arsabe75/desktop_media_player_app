# desktop_media_player_app

## Overview
- This application is a desktop video player for Linux and Windows, built with Flutter and media_kit. It supports playing local video files and network URLs. (Tested on Kubuntu 24.04 and Windows 11)

## Verification Steps

### Prerequisites
- Ensure you have mpv and libmpv-dev installed on Linux:
#### sudo apt-get install libmpv-dev mpv
- On Windows, the necessary DLLs are handled automatically.

### Running the App
Run the application using Flutter:
#### flutter run -d linux
or
#### flutter run -d windows

## Testing Features
### Open Local File
- Click the "Open Local File" button.
- Select a video file (e.g., .mp4, .mkv).
- Verify: The video should start playing immediately.
### Open Video URL
- Click the "Open Video URL" button.
- Enter a valid video URL (e.g., https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4).
- Click "Play".
- Verify: The video should load and play.

## Controles del reproductor que están implementados y activos:

### 1. Barra Superior (Top Bar)
- Botón de Retroceso: Un botón estándar (BackButton) para volver a la pantalla anterior.
- Título del Video: Muestra el nombre del archivo o título del video que se está reproduciendo.
### 2. Gestos en el Área de Video
- Un Toque (Click/Tap): Alterna entre reproducir y pausar el video.
- Doble Toque (Double Click/Tap): Alterna entre modo pantalla completa y modo ventana.
### 3. Barra de Controles Inferior
#### Barra de Progreso (Seek Bar):
- Muestra el tiempo actual de reproducción.
- Barra deslizante (Slider) para saltar a una posición específica del video.
- Muestra la duración total del video.
#### Botón Reproducir/Pausar:
- Un botón dedicado en la esquina inferior izquierda.
#### Control de Volumen:
- Icono de altavoz: Si se presiona se alterna entre mute y unmute.
- Barra deslizante (Slider) para ajustar el volumen de 0 a 100.
#### Botón de Pantalla Completa:
- Un botón dedicado en la esquina inferior derecha para alternar el modo de pantalla.
### 4. Comportamiento de Visibilidad
#### Auto-ocultar:
- Los controles desaparecen automáticamente después de 3 segundos de inactividad.
#### Reaparecer:
- Los controles vuelven a aparecer al mover el mouse sobre el reproductor o al hacer clic en la pantalla.

## Actualmente, las siguientes teclas están configuradas para controlar la reproducción y la apariencia del reproductor:

### Controles de Reproducción
- Espacio (Space): Alterna entre Reproducir y Pausar.
- Flecha Derecha (Arrow Right): Adelanta el video 10 segundos.
- Flecha Izquierda (Arrow Left): Retrocede el video 10 segundos.
### Controles de Apariencia
- Tecla F (F): Alterna entre Pantalla Completa y modo ventana.

### Controles de Volumen
- Tecla M (M): Alterna entre Mute y Volumen.

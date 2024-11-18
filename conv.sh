#!/bin/bash

# Verifica se il nome del file PDF è stato fornito
if [ $# -lt 1 ]; then
  echo "Uso: $0 input.pdf [output.txt]"
  exit 1
fi

INPUT_PDF="$1"
OUTPUT_TXT="${2:-output_text.txt}"

# Verifica che il file di input esista
if [ ! -f "$INPUT_PDF" ]; then
  echo "Errore: Il file '$INPUT_PDF' non esiste."
  exit 1
fi

# Crea directory temporanee
TEMP_DIR=$(mktemp -d)
IMAGES_DIR="$TEMP_DIR/images"
SPLIT_DIR="$TEMP_DIR/split"

mkdir -p "$IMAGES_DIR" "$SPLIT_DIR"

echo "Convertendo il PDF in immagini PNG..."
# Converti ogni pagina del PDF in un'immagine PNG ad alta risoluzione
pdftoppm -png -r 300 "$INPUT_PDF" "$IMAGES_DIR/page"

echo "Suddividendo le immagini in due metà verticali..."
# Determina il numero totale di pagine per impostare lo zero-padding
TOTAL_PAGES=$(ls "$IMAGES_DIR"/*.png | wc -l)
# Calcola il numero di cifre necessarie per lo zero-padding
PAD_WIDTH=$(echo $TOTAL_PAGES | awk '{printf "%d", log($1)/log(10)+1}')

# Per ogni immagine, suddividi in due metà
PAGE_NUMBER=1
for img in "$IMAGES_DIR"/*.png; do
  # Ottieni le dimensioni dell'immagine
  width=$(identify -format "%w" "$img")
  height=$(identify -format "%h" "$img")
  half_width=$((width / 2))

  # Formatta il numero di pagina con zero-padding
  formatted_page=$(printf "%0${PAD_WIDTH}d" "$PAGE_NUMBER")

  # Estrai la metà sinistra usando magick
  magick "$img" -crop "${half_width}x${height}+0+0" +repage "$SPLIT_DIR/page_${formatted_page}_left.png"

  # Estrai la metà destra usando magick
  magick "$img" -crop "${half_width}x${height}+${half_width}+0" +repage "$SPLIT_DIR/page_${formatted_page}_right.png"

  PAGE_NUMBER=$((PAGE_NUMBER + 1))
done

echo "Eseguendo l'OCR sulle immagini suddivise e raccogliendo il testo..."
# Inizializza o svuota il file di output
> "$OUTPUT_TXT"

for split_img in $(ls "$SPLIT_DIR"/*_left.png "$SPLIT_DIR"/*_right.png | sort); do
  # Estrai informazioni dal nome del file
  filename=$(basename "$split_img" .png)
  
  # Estrai il numero di pagina e il lato (left/right) usando parameter expansion di Bash
  # Supponendo che il formato del filename sia page_X_left o page_X_right
  page_num=${filename#page_}        # Rimuove 'page_' dall'inizio
  page_num=${page_num%%_*}          # Rimuove tutto dopo il primo '_', ottenendo solo il numero di pagina

  side=${filename#*_}               # Rimuove 'page_X_' ottenendo 'left' o 'right'

  # Mappa 'left' e 'right' a 'Left' e 'Right'
  if [ "$side" == "left" ]; then
    side_full="Left"
  elif [ "$side" == "right" ]; then
    side_full="Right"
  else
    side_full="$side"
  fi

  # Aggiungi un'intestazione al file di testo
  echo -e "===== Page $page_num - $side_full =====\n" >> "$OUTPUT_TXT"

  # Esegui l'OCR e appendi il testo al file di output
  tesseract "$split_img" stdout -l eng >> "$OUTPUT_TXT"

  # Aggiungi una nuova linea per separare le sezioni
  echo -e "\n\n" >> "$OUTPUT_TXT"
done

echo "Pulizia dei file temporanei..."
# Rimuovi la directory temporanea
rm -rf "$TEMP_DIR"

echo "Processo completato. Il testo estratto si trova in: $OUTPUT_TXT"

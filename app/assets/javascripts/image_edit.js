function ImageEdit (opts) {
  var attribute = opts.attribute || 'picture'

  this.opts = opts
  this.fileEl = $('#file_' + attribute)
  this.previewEl = $('#preview_' + attribute).attr('src', opts.url)
  this.rotateEl = $('#rotate_' + attribute)
  this.zoomInEl = $('#zoom_in_' + attribute)
  this.zoomOutEl = $('#zoom_out_' + attribute)
  this.base64El = $('#' + opts.resource + '_base64_' + attribute)
  this.readFile = this.readFile.bind(this)
  this.initFileOnChange = this.initFileOnChange.bind(this)
  this.initCroppie = this.initCroppie.bind(this)
  this.updateResult = this.updateResult.bind(this)
}

ImageEdit.prototype.readFile = function (input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader()

    if (this.cropper) {
      this.cropper.destroy()
    }

    reader.onload = function (_) {
      this.previewEl[0].src = reader.result
      this.initCroppie()
    }.bind(this)

    reader.readAsDataURL(input.files[0])
  }
}

ImageEdit.prototype.initFileOnChange = function () {
  var imageEdit = this
  this.readFile(this.fileEl[0])
  this.fileEl.on('change', function () { imageEdit.readFile(this) })
}

ImageEdit.prototype.initCroppie = function () {
  if (!this.previewEl[0].src) {
    return
  }
  this.cropper = new Cropper(this.previewEl[0], {
    zoomable: !!this.opts.showzoomer,
    autoCrop: false,
    autoCropArea: 1,
    aspectRatio: this.opts.enableresize ? NaN : this.opts.width / this.opts.height,
    ready: function () {
      var canvas = this.cropper.initialCanvasData
      this.cropper.zoomTo(
        canvas.width / (canvas.naturalWidth + 1), {
          x: canvas.width / 2,
          y: canvas.height / 2
        }
      ).crop()
      this.updateResult()
    }.bind(this)
  })
  this.previewEl[0].addEventListener('cropend', this.updateResult)
  this.rotateEl.parent().on('click', function () {
    this.cropper.rotate(-90)
    this.updateResult()
  }.bind(this))
  this.zoomInEl.parent().on('click', function () {
    this.cropper.zoom(0.1)
    this.updateResult()
  }.bind(this))
  this.zoomOutEl.parent().on('click', function () {
    this.cropper.zoom(-0.1)
    this.updateResult()
  }.bind(this))
}

ImageEdit.prototype.updateResult = function () {
  var canvas = this.cropper.getCroppedCanvas()
  if (canvas) {
    this.base64El.val(canvas.toDataURL())
  }
}

$(document).ready(function () {
  $('.image-edit-upload').each(function (_, upload) {
    var imageEdit = new ImageEdit($(upload).data('imageedit'))
    imageEdit.initFileOnChange()
    imageEdit.initCroppie()
  })
})

function ImageEdit (opts) {
  var attribute = opts.attribute || 'picture'

  this.fileEl = $('#file_' + attribute)
  this.previewEl = $('#preview_' + attribute)
  this.rotateEl = $('#rotate_' + attribute)
  this.base64El = $('#' + opts.resource + '_base64_' + attribute)
  this.croppieInstance = this.previewEl.croppie({
    boundary: {
      width: (opts.width || 330) + 100,
      height: (opts.height || 192) + 100
    },
    viewport: {
      width: opts.width || 330,
      height: opts.height || 192
    },
    enableExif: true,
    enableOrientation: true,
    url: opts.url,
    showZoomer: !!opts.showzoomer,
    enableResize: !!opts.enableresize
  })
  this.readFile = this.readFile.bind(this)
  this.initFileOnChange = this.initFileOnChange.bind(this)
  this.initCroppie = this.initCroppie.bind(this)
  this.updateResult = this.updateResult.bind(this)
}

ImageEdit.prototype.readFile = function (input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader()

    reader.onload = function (e) {
      this.previewEl.addClass('ready')
      this.croppieInstance.croppie('bind', {
        url: e.target.result
      }).then(function () {
        this.croppieInstance.croppie('setZoom', 0)
      }.bind(this))
      this.updateResult()
    }.bind(this)

    reader.readAsDataURL(input.files[0])
  }
}

ImageEdit.prototype.initFileOnChange = function () {
  var imageEdit = this
  this.readFile(this.fileEl[0])
  this.fileEl.on('change', function () { imageEdit.readFile(this) })
  this.rotateEl.on('click', function () {
    imageEdit.croppieInstance.croppie('rotate', -90)
    this.updateResult()
  }.bind(this))
}

ImageEdit.prototype.initCroppie = function () {
  this.croppieInstance.on('update.croppie', this.updateResult)
  this.rotateEl.appendTo(this.previewEl)
}

ImageEdit.prototype.updateResult = function () {
  this.croppieInstance.croppie('result', 'base64').then(
    function (base64) {
      this.base64El.val(base64)
    }.bind(this)
  )
}

$(document).ready(function () {
  $('.image-edit-upload').each(function (_, upload) {
    var imageEdit = new ImageEdit($(upload).data('imageedit'))
    imageEdit.initFileOnChange()
    imageEdit.initCroppie()
  })
})
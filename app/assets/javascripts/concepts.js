var __bind = function (fn, me) {
        return function () {
            return fn.apply(me, arguments);
        };
    },
    __hasProp = {}.hasOwnProperty,
    __extends = function (child, parent) {
        for (var key in parent) {
            if (__hasProp.call(parent, key)) child[key] = parent[key];
        }
        function ctor() {
            this.constructor = child;
        }

        ctor.prototype = parent.prototype;
        child.prototype = new ctor();
        child.__super__ = parent.prototype;
        return child;
    };

Annotator.Plugin.Concepts = (function (_super) {

    __extends(Concepts, _super);

    function Concepts() {
        this.setAnnotationTags = __bind(this.setAnnotationTags, this);

        this.updateField = __bind(this.updateField, this);
        return Concepts.__super__.constructor.apply(this, arguments);
    }

    Concepts.prototype.options = {
        parseTags: function (string) {
            var tags;
            string = $.trim(string);
            tags = [];
            //if (string) {
            //  tags = string.split(/\s+/);
            //}
            tags = [string]
            return tags;
        },
        stringifyTags: function (array) {
            return array.join(" ");
        }
    };

    Concepts.prototype.field = null;

    Concepts.prototype.input = null;

    Concepts.prototype.pluginInit = function () {
        if (!Annotator.supported()) {
            return;
        }
        this.annotator
            .subscribe('annotationEditorHidden', function (annotation) {
                initDataAndTabs(false);
            })
            .subscribe('annotationEditorSubmit', function (annotation) {
                var annotator = $(document.body).annotator().data('annotator');

                annotator.plugins.Store.options.annotationData.chunk = $(annotation.annotation.highlights[0]).parents().eq(3).attr('id');

            });


    /*    this.annotator
            .subscribe("annotationViewerShown", function (annotation) {
                $(".annotator-link[href*='View as webpage']").css('display', 'none');
                $('.annotator-controls').nextAll().eq(0).css('display', 'none');
                $('.annotator-controls').nextAll().eq(1).css('display', 'none');
                $('.annotator-controls').nextAll().eq(2).css('display', 'none');
            })
            .subscribe("annotationViewerHidden", function (annotation) {
                $(".annotator-link[href*='View as webpage']").css('display', 'block')
                $('.annotator-controls').nextAll().eq(0).css('display', 'block');
                $('.annotator-controls').nextAll().eq(1).css('display', 'block');
                $('.annotator-controls').nextAll().eq(2).css('display', 'block');
            })
            .subscribe('annotationEditorShown', function (annotation) {
                $('#annotator-field-0').css('display', 'none');
                $('#annotator-field-1').css('display', 'none');
                $('#annotator-field-4').css('display', 'none');
                $('#annotator-field-5').css('display', 'none');
                $('.annotator-checkbox').css('display', 'none');
                console.info("The annotation: %o has just been created!", annotation)

            })
            .subscribe('annotationEditorHidden', function (annotation) {
                $('#annotator-field-0').css('display', 'block');
                $('#annotator-field-1').css('display', 'block');
                $('#annotator-field-4').css('display', 'block');
                $('#annotator-field-5').css('display', 'block');
                $('.annotator-checkbox').css('display', 'block');
                console.info("The annotation: %o has just been created!", annotation)
            });      */
        this.field = this.annotator.editor.addField({
            label: Annotator._t('Add some tags here') + '\u2026',
            load: this.updateField,
            submit: this.setAnnotationTags
        });
        this.annotator.viewer.addField({
            load: this.updateViewer
        });
        if (this.annotator.plugins.Filter) {
            this.annotator.plugins.Filter.addFilter({
                label: Annotator._t('Tag'),
                property: 'tags',
                isFiltered: Annotator.Plugin.Tags.filterCallback
            });
        }
        return this.input = $(this.field).find(':input');
    };

    Concepts.prototype.parseTags = function (string) {
        return this.options.parseTags(string);
    };

    Concepts.prototype.stringifyTags = function (array) {
        return this.options.stringifyTags(array);
    };

    Concepts.prototype.updateField = function (field, annotation) {
        var value;
        value = '';
        if (annotation.tags) {
            value = this.stringifyTags(annotation.tags);
        }
        return this.input.val(value);
    };

    Concepts.prototype.setAnnotationTags = function (field, annotation) {
        return annotation.tags = this.parseTags(this.input.val());
    };

    Concepts.prototype.updateViewer = function (field, annotation) {
        field = $(field);
        if (annotation.tags && $.isArray(annotation.tags) && annotation.tags.length) {
            return field.addClass('annotator-tags').html(function () {
                var string;
                return string = $.map(annotation.tags,function (tag) {
                    return '<span class="annotator-tag">' + Annotator.Util.escape(tag) + '</span>';
                }).join(' ');
            });
        } else {
            return field.remove();
        }
    };

    return Concepts;

})(Annotator.Plugin);

Annotator.Plugin.Concepts.filterCallback = function (input, tags) {
    var keyword, keywords, matches, tag, _i, _j, _len, _len1;
    if (tags == null) {
        tags = [];
    }
    matches = 0;
    keywords = [];
    if (input) {
        keywords = input.split(/\s+/g);
        for (_i = 0, _len = keywords.length; _i < _len; _i++) {
            keyword = keywords[_i];
            if (tags.length) {
                for (_j = 0, _len1 = tags.length; _j < _len1; _j++) {
                    tag = tags[_j];
                    if (tag.indexOf(keyword) !== -1) {
                        matches += 1;
                    }
                }
            }
        }
    }
    return matches === keywords.length;
};

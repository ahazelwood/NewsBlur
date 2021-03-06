NEWSBLUR.ReaderAccount = function(options) {
    var defaults = {};
        
    this.options = $.extend({}, defaults, options);
    this.model   = NEWSBLUR.AssetModel.reader();

    this.runner();
};

NEWSBLUR.ReaderAccount.prototype = new NEWSBLUR.Modal;
NEWSBLUR.ReaderAccount.prototype.constructor = NEWSBLUR.ReaderAccount;

_.extend(NEWSBLUR.ReaderAccount.prototype, {
    
    runner: function() {
        this.make_modal();
        this.open_modal();

        this.$modal.bind('click', $.rescope(this.handle_click, this));
        this.handle_change();
    },
    
    make_modal: function() {
        var self = this;
        
        this.$modal = $.make('div', { className: 'NB-modal-preferences NB-modal-account NB-modal' }, [
            $.make('a', { href: '#preferences', className: 'NB-link-account-preferences NB-splash-link' }, 'Switch to Preferences'),
            $.make('h2', { className: 'NB-modal-title' }, 'My Account'),
            $.make('form', { className: 'NB-preferences-form' }, [
                $.make('div', { className: 'NB-preference NB-preference-username' }, [
                    $.make('div', { className: 'NB-preference-options' }, [
                        $.make('div', { className: 'NB-preference-option' }, [
                            $.make('input', { id: 'NB-preference-username', type: 'text', name: 'username', value: NEWSBLUR.Globals.username })
                        ])
                    ]),
                    $.make('div', { className: 'NB-preference-label'}, [
                        $.make('label', { 'for': 'NB-preference-username' }, 'Username'),

                        $.make('div', { className: 'NB-preference-error'})
                    ])
                ]),
                $.make('div', { className: 'NB-preference NB-preference-email' }, [
                    $.make('div', { className: 'NB-preference-options' }, [
                        $.make('div', { className: 'NB-preference-option' }, [
                            $.make('input', { id: 'NB-preference-email', type: 'text', name: 'email', value: NEWSBLUR.Globals.email })
                        ])
                    ]),
                    $.make('div', { className: 'NB-preference-label'}, [
                        $.make('label', { 'for': 'NB-preference-email' }, 'Email address'),

                        $.make('div', { className: 'NB-preference-error'})
                    ])
                ]),
                $.make('div', { className: 'NB-preference NB-preference-password' }, [
                    $.make('div', { className: 'NB-preference-options' }, [
                        $.make('div', { className: 'NB-preference-option' }, [
                            $.make('label', { 'for': 'NB-preference-password-old' }, 'Old password'),
                            $.make('input', { id: 'NB-preference-password-old', type: 'password', name: 'old_password', value: '' })
                        ]),
                        $.make('div', { className: 'NB-preference-option' }, [
                            $.make('label', { 'for': 'NB-preference-password-new' }, 'New password'),
                            $.make('input', { id: 'NB-preference-password-new', type: 'password', name: 'new_password', value: '' })
                        ])
                    ]),
                    $.make('div', { className: 'NB-preference-label'}, [
                        'Change password',
                        $.make('div', { className: 'NB-preference-error'})
                    ])
                ]),
                $.make('div', { className: 'NB-preference NB-preference-premium' }, [
                    $.make('div', { className: 'NB-preference-options' }, [
                        (!NEWSBLUR.Globals.is_premium && $.make('a', { className: 'NB-modal-submit-button NB-modal-submit-green NB-account-premium-modal' }, 'Go Premium!')),
                        (NEWSBLUR.Globals.is_premium && $.make('div', [
                            'Thank you! You have a ',
                            $.make('b', 'premium account'),
                            '.'
                        ]))
                    ]),
                    $.make('div', { className: 'NB-preference-label'}, [
                        'Premium'
                    ])
                ]),
                $.make('div', { className: 'NB-preference NB-preference-opml' }, [
                    $.make('div', { className: 'NB-preference-options' }, [
                        $.make('a', { className: 'NB-splash-link', href: NEWSBLUR.URLs['opml-export'] }, 'Download OPML')
                    ]),
                    $.make('div', { className: 'NB-preference-label'}, [
                        'Backup your sites',
                        $.make('div', { className: 'NB-preference-sublabel' }, 'Download this XML file as a backup')
                    ])
                ]),
                $.make('div', { className: 'NB-modal-submit' }, [
                    $.make('input', { type: 'submit', disabled: 'true', className: 'NB-modal-submit-green NB-disabled', value: 'Change what you like above...' }),
                    ' or ',
                    $.make('a', { href: '#', className: 'NB-modal-cancel' }, 'cancel')
                ])
            ]).bind('submit', function(e) {
                e.preventDefault();
                self.save_account_settings();
                return false;
            })
        ]);
    },
    
    close_and_load_preferences: function() {
      this.close(function() {
          NEWSBLUR.reader.open_preferences_modal();
      });
    },
    
    close_and_load_premium: function() {
      this.close(function() {
          NEWSBLUR.reader.open_feedchooser_modal();
      });
    },
    
    handle_cancel: function() {
        var $cancel = $('.NB-modal-cancel', this.$modal);
        
        $cancel.click(function(e) {
            e.preventDefault();
            $.modal.close();
        });
    },
        
    serialize_preferences: function() {
        var preferences = {};

        $('input[type=radio]:checked, select, input', this.$modal).each(function() {
            var name       = $(this).attr('name');
            var preference = preferences[name] = $(this).val();
            if (preference == 'true')       preferences[name] = true;
            else if (preference == 'false') preferences[name] = false;
        });
        $('input[type=checkbox]', this.$modal).each(function() {
            preferences[$(this).attr('name')] = $(this).is(':checked');
        });

        return preferences;
    },
    
    save_account_settings: function() {
        var self = this;
        var form = this.serialize_preferences();
        $('.NB-preference-error', this.$modal).text('');
        $('input[type=submit]', this.$modal).val('Saving...').attr('disabled', true).addClass('NB-disabled');
        
        this.model.save_account_settings(form, function(data) {
            if (data.code == -1) {
                $('.NB-preference-username .NB-preference-error', this.$modal).text(data.message);
                return self.disable_save();
            } else if (data.code == -2) {
                $('.NB-preference-email .NB-preference-error', this.$modal).text(data.message);
                return self.disable_save();
            } else if (data.code == -3) {
                $('.NB-preference-password .NB-preference-error', this.$modal).text(data.message);
                return self.disable_save();
            }
            
            NEWSBLUR.Globals.username = data.payload.username;
            NEWSBLUR.Globals.email = data.payload.email;
            $('.NB-module-account-username').text(NEWSBLUR.Globals.username);
            self.close();
        });
    },
    
    // ===========
    // = Actions =
    // ===========

    handle_click: function(elem, e) {
        var self = this;
        
        $.targetIs(e, { tagSelector: '.NB-account-premium-modal' }, function($t, $p) {
            e.preventDefault();
            
            self.close_and_load_premium();
        });        
        $.targetIs(e, { tagSelector: '.NB-link-account-preferences' }, function($t, $p) {
            e.preventDefault();
            
            self.close_and_load_preferences();
        });
        $.targetIs(e, { tagSelector: '.NB-modal-cancel' }, function($t, $p) {
            e.preventDefault();
            
            self.close();
        });
    },
    
    handle_change: function() {
        $('input[type=radio],input[type=checkbox],select,input', this.$modal).bind('change', _.bind(this.enable_save, this));
        $('input', this.$modal).bind('keydown', _.bind(this.enable_save, this));
    },
    
    enable_save: function() {
        $('input[type=submit]', this.$modal).removeAttr('disabled').removeClass('NB-disabled').val('Save My Account');
    },
    
    disable_save: function() {
        this.resize();
        $('input[type=submit]', this.$modal).attr('disabled', true).addClass('NB-disabled').val('Change what you like above...');
    }
    
});
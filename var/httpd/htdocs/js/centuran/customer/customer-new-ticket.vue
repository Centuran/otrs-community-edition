<template>
  <v-container>
    <v-row>
      <v-col cols="12" md="8" offset-md="2" class="message">
        <h2 v-html="`${Core.Language.Translate('New Ticket')}`"></h2>
                
        <v-card>
          <v-form>
            <v-container>
              <v-row class="align-baseline" v-if="types.length">
                <v-col
                  cols="12" sm="3"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <label
                    v-html="`${Core.Language.Translate('Type')}:`"
                    class="mb-1 mt-3 mr-4"
                  ></label>
                </v-col>
                <v-col
                  cols="12" sm="9" md="6"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <v-select
                    id="msg_type"
                    v-model="msg.type"
                    dense
                    outlined
                    :items="types"
                    item-text="name"
                    item-value="value"
                    :rules="[ val(validateType) ]"
                    class="tooltip-error"
                  >
                    <template v-slot:item="{ item, on, attrs }">
                      <v-list-item
                        v-on="on"
                        v-bind="attrs"
                        :value="item.value"
                        class="select-item"
                      >
                        {{ item.name }}
                      </v-list-item>
                    </template>
                    
                    <template v-slot:message="{ message }">
                      <v-tooltip bottom
                        :attach="document.querySelector('#msg_type').parentElement.parentElement.parentElement"
                        color="error"
                        dark
                        v-model="message"
                      >
                        <span>{{ message }}</span>
                      </v-tooltip>
                    </template>
                  </v-select>
                </v-col>
              </v-row>

              <v-row v-if="queues.length" 
                class="align-baseline"
              >
                <v-col
                  cols="12" sm="3"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <label
                    v-html="`${Core.Language.Translate('To')}:`"
                    class="mb-1 mt-3 mr-4"
                  ></label>
                </v-col>
                <v-col
                  cols="12" sm="9" md="6"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <v-select
                    id="message_queue"
                    v-model="msg.queue"
                    dense
                    outlined
                    :items="queues"
                    item-text="name"
                    item-value="value"
                    :menu-props="{ attach: '#message_queue' }"
                    :rules="[ val(validateQueue) ]"
                    class="tooltip-error"
                  >
                    <template v-slot:item="{ item, on, attrs }">
                      <v-list-item
                        v-on="on"
                        v-bind="attrs"
                        :value="item.value"
                        class="select-item"
                      >
                        {{ item.name }}
                      </v-list-item>
                    </template>

                    <template v-slot:message="{ message }">
                      <v-tooltip bottom
                        :attach="document.querySelector('#message_queue').parentElement.parentElement.parentElement"
                        color="error"
                        dark
                        v-model="message"
                      >
                        <span>{{ message }}</span>
                      </v-tooltip>
                    </template>
                  </v-select>
                </v-col>
              </v-row>

              <v-row class="align-baseline" v-if="services.length">
                <v-col
                  cols="12" sm="3"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <label
                    v-html="`${Core.Language.Translate('Service')}:`"
                    class="mb-1 mt-3 mr-4"
                  ></label>
                </v-col>
                <v-col
                  cols="12" sm="9" md="6"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <v-select
                    id="msg_service"
                    v-model="msg.service"
                    dense
                    outlined
                    :items="services"
                    item-text="name"
                    item-value="value"
                    :rules="[ val(validateService) ]"
                    class="tooltip-error"
                  >
                    <template v-slot:item="{ item, on, attrs }">
                      <v-list-item
                        v-on="on"
                        v-bind="attrs"
                        :value="item.value"
                        class="select-item"
                      >
                        {{ item.name }}
                      </v-list-item>
                    </template>
                  
                    <template v-slot:message="{ message }">
                      <v-tooltip bottom
                        :attach="document.querySelector('#msg_service').parentElement.parentElement.parentElement"
                        color="error"
                        dark
                        v-model="message"
                      >
                        <span>{{ message }}</span>
                      </v-tooltip>
                    </template>
                  </v-select>
                </v-col>
              </v-row>

              <v-row class="align-baseline" v-if="sla.length">
                <v-col
                  cols="12" sm="3"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <label
                    v-html="`${Core.Language.Translate('SLA')}:`"
                    class="mb-1 mt-3 mr-4"
                  ></label>
                </v-col>
                <v-col
                  cols="12" sm="9" md="6"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <v-select
                    id="msg_sla"
                    v-model="msg.sla"
                    dense
                    outlined
                    :items="sla"
                    item-text="name"
                    item-value="value"
                    :rules="[ val(validateSLA) ]"
                    class="tooltip-error"
                  >
                    <template v-slot:item="{ item, on, attrs }">
                      <v-list-item
                        v-on="on"
                        v-bind="attrs"
                        :value="item.value"
                        class="select-item"
                      >
                        {{ item.name }}
                      </v-list-item>
                    </template>

                    <template v-slot:message="{ message }">
                      <v-tooltip bottom
                        :attach="document.querySelector('#msg_sla').parentElement.parentElement.parentElement"
                        color="error"
                        dark
                        v-model="message"
                      >
                        <span>{{ message }}</span>
                      </v-tooltip>
                    </template>
                  </v-select>
                </v-col>
              </v-row>

              <v-row class="align-baseline">
                <v-col
                  cols="12" sm="3"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <label
                    v-html="`${Core.Language.Translate('Subject')}:`"
                    class="mb-1 mt-3 mr-4"
                  ></label>
                </v-col>
                <v-col
                  cols="12" sm="9"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <v-text-field
                    id="msg_subject"
                    v-model="msg.subject"
                    dense
                    outlined
                    :rules="[ val('required') ]"
                    class="tooltip-error"
                  >
                    <template v-slot:message="{ message }">
                      <v-tooltip bottom
                        :attach="document.querySelector('#msg_subject').parentElement.parentElement.parentElement"
                        color="error"
                        dark
                        v-model="message"
                      >
                        <span>{{ message }}</span>
                      </v-tooltip>
                    </template>
                  </v-text-field>
                </v-col>
              </v-row>

              <v-row class="align-baseline" v-if="priorities.length">
                <v-col
                  cols="12" sm="3"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <label
                    v-html="`${Core.Language.Translate('Priority')}:`"
                    class="mb-1 mt-3 mr-4"
                  ></label>
                </v-col>
                <v-col
                  cols="12" sm="9" md="6"
                  class="pb-0 pt-0 pt-sm-2"
                >
                  <v-select
                    v-model="msg.priority"
                    dense
                    outlined
                    :items="priorities"
                    item-text="name"
                    item-value="value"
                    class="tooltip-error"
                  >
                    <template v-slot:item="{ item, on, attrs }">
                      <v-list-item
                        v-on="on"
                        v-bind="attrs"
                        :value="item.value"
                      >
                        <span
                          class="priority-color"
                          :style="`background: ${item.color}`"
                        >&nbsp;</span>
                        {{ item.name }}
                      </v-list-item>
                    </template>

                    <template v-slot:selection="{ item }">
                      <span
                        class="priority-color"
                        :style="`background: ${item.color}`"
                      >&nbsp;</span>
                      {{ item.name }}
                    </template>
                  </v-select>
                </v-col>
              </v-row>

              <v-row v-for="(field, i) in dynamicFields"
                class="align-baseline"
              >
                <template v-if="field.type == 'text'">
                  <v-col cols="12" sm="3"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <label
                      v-html="`${field.label}:`"
                      class="mb-1 mt-3 mr-4"
                    ></label>
                  </v-col>
                  <v-col
                    cols="12" sm="9" md="6"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <v-text-field
                      :id="`df_${field.name}`"
                      v-model="msg.dynamicFields[field.name]"
                      dense
                      outlined
                      :rules="[
                        val(validateDynamicField, { field: field })
                      ]"
                      :error-messages="field.serverError ? [ field.serverError ] : []"
                      :error="field.serverError ? true : false"                   
                      class="tooltip-error"
                      @change="function () { field.serverError = false; }"
                    >
                      <template v-slot:message="{ message }">
                        <v-tooltip bottom
                          :attach="field.errorAttach"
                          color="error"
                          dark
                          v-model="message"
                        >
                          <span>{{ message }}</span>
                        </v-tooltip>
                      </template>
                    </v-text-field>
                  </v-col>
                </template>

                <template v-if="field.type == 'textarea'">
                  <v-col cols="12" sm="3"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <label
                      v-html="`${field.label}:`"
                      class="mb-1 mt-3 mr-4"
                    ></label>
                  </v-col>
                  <v-col
                    cols="12" sm="9"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <v-textarea
                      :id="`df_${field.name}`"
                      v-model="msg.dynamicFields[field.name]"
                      dense
                      outlined
                      :rows="field.row.querySelector('textarea').rows"
                    ></v-textarea>
                  </v-col>
                </template>
                
                <template v-if="field.type == 'dropdown'">
                  <v-col cols="12" sm="3"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <label
                      v-html="`${field.label}:`"
                      class="mb-1 mt-3 mr-4"
                    ></label>
                  </v-col>
                  <v-col
                    cols="12" sm="9" md="6"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <v-select
                      :id="`df_${field.name}`"
                      v-model="msg.dynamicFields[field.name]"
                      dense
                      outlined
                      :items="field.options"
                      item-text="name"
                      item-value="value"
                      :rules="[
                        val(validateDynamicField, { field: field })
                      ]"
                      :error-messages="field.serverError ? [ field.serverError ] : []"
                      :error="field.serverError ? true : false"
                      class="tooltip-error"
                      @change="function () { field.serverError = false; }"
                    >
                      <template v-slot:item="{ item, on, attrs }">
                        <v-list-item
                          v-on="on"
                          v-bind="attrs"
                          :value="item.value"
                          class="select-item"
                        >
                          {{ item.name }}
                        </v-list-item>
                      </template>
                    
                      <template v-slot:message="{ message }">
                        <v-tooltip bottom
                          :attach="field.errorAttach"
                          color="error"
                          dark
                          v-model="message"
                        >
                          <span>{{ message }}</span>
                        </v-tooltip>
                      </template>
                    </v-select>
                  </v-col>
                </template>

                <template v-if="field.type == 'multiselect'">
                  <v-col cols="12" sm="3"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <label
                      v-html="`${field.label}:`"
                      class="mb-1 mt-3 mr-4"
                    ></label>
                  </v-col>
                  <v-col
                    cols="12" sm="9" md="6"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <v-select
                      :id="`df_${field.name}`"
                      v-model="msg.dynamicFields[field.name]"
                      multiple
                      dense
                      outlined
                      chips
                      :items="field.options"
                      item-text="name"
                      item-value="value"
                      :rules="[
                        val(validateDynamicField, { field: field })
                      ]"
                      :error-messages="field.serverError ? [ field.serverError ] : []"
                      :error="field.serverError ? true : false"
                      class="tooltip-error"
                      @change="function () { field.serverError = false; }"
                    >
                      <!-- <template v-slot:item="{ item, on, attrs }">
                        <v-list-item
                          v-on="on"
                          v-bind="attrs"
                          :value="item.value"
                          class="select-item"
                        >
                          {{ item.name }}
                        </v-list-item>
                      </template> -->
                    
                      <template v-slot:message="{ message }">
                        <v-tooltip bottom
                          :attach="field.errorAttach"
                          color="error"
                          dark
                          v-model="message"
                        >
                          <span>{{ message }}</span>
                        </v-tooltip>
                      </template>
                    </v-select>
                  </v-col>
                </template>

                <template v-if="field.type == 'date'">
                  <v-col cols="12" sm="3"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <label
                      v-html="`${field.label}:`"
                      class="mb-1 mt-3 mr-4"
                    ></label>
                  </v-col>
                  <v-col
                    cols="12" sm="9" md="6"
                    class="pb-0 pt-0 pt-sm-2"
                  >
                    <datetimepicker
                      :original-field="field.row.querySelector('.Field')"
                    ></datetimepicker>
                  </v-col>
                </template>

                <template v-if="field.type == 'checkbox'">
                  <v-col cols="12" class="pb-0 pt-0">
                    <v-checkbox
                      v-model="msg.dynamicFields[field.name]"
                      dense
                      hide-details
                      :label="field.label"
                    ></v-checkbox>
                  </v-col>
                </template>
              </v-row>

              <v-row class="my-0">
                <v-col class="pt-2">
                  <label
                    v-html="`${Core.Language.Translate('Text')}:`"
                    class="above mb-1 mt-4"
                  ></label>
                  <ckeditor
                    v-model="msgText"
                    :config="editorConfig"
                    tag-type="textarea"
                    class="cmt-ckeditor tooltip-error"
                    @ready="onEditorReady"
                  ></ckeditor>

                  <v-tooltip bottom
                    absolute
                    attach=".cmt-ckeditor"
                    color="error"
                    dark
                    v-model="msgTextInvalid"
                  >
                    <span>{{ msgTextError }}</span>
                  </v-tooltip>
                </v-col>
              </v-row>

              <v-row class="my-0">
                <v-col class="py-0">
                  <label
                    v-html="`${Core.Language.Translate('Attachments')}:`"
                    class="above mb-1 mt-1"
                  ></label>
                  <div class="attachments"
                    @click="document.querySelector('.DnDUpload').click()"
                  >
                    <div v-if="msg.attachments.length > 0">
                      <v-chip v-for="(attachment, i) in msg.attachments"
                      class="ma-2"
                      color="rgb(224, 224, 224)"
                      @click="event => event.stopPropagation()"
                    >
                      <v-icon left>
                        mdi-attachment
                      </v-icon>
                      {{ attachment.fileName }}
                      <span class="size text--disabled pl-1">
                        ({{attachment.fileSize }})
                      </span>
                      <v-icon right
                        @click="event => { attachment.deleteElement.click(); event.stopPropagation(); }">
                        mdi-delete
                      </v-icon>
                    </v-chip>
                    </div>
                    <div class="hint text-center">
                      <p
                        v-html="`${Core.Language.Translate('Drop files here or click to browse')}`"
                        class="font-weight-medium mb-2"
                      ></p>
                      <v-icon
                        class="mb-4"
                      >
                        mdi-upload
                      </v-icon>
                    </div>
                  </div>
                </v-col>
              </v-row>

            </v-container>
          </v-form>
        </v-card>

        <div class="mt-6 text-right pr-3">
          <v-btn
            large
            color="rgb(33, 150, 243)"
            class="font-weight-medium px-8 white--text"
            @click="submitMsg()"
            :disabled="!msgValid"
            v-html="`${Core.Language.Translate('Send')}`"
          ></v-btn>
        </div>

      </v-col>
    </v-row>
  </v-container>
</template>

<script>
// Shorter version of querySelector
function sel(selector, context) {
  context ||= document;
  return context.querySelector(selector);
}

// Shorter version of querySelectorAll
function selAll(selector, context) {
  context ||= document;
  return context.querySelectorAll(selector);
}

module.exports = {
  data: function () {
    return {
      editorConfig: {},
      
      dynamicFields:  [],
      queues:         [],
      priorities:     [],
      priorityColors: {},
      services:       [],
      sla:            [],
      types:          [],

      msg: {
        attachments:   [],
        queue:         null,
        priority:      '',
        subject:       '',
        text:          '',
        type:          null,
        service:       null,
        sla:           null,
        dynamicFields: {},
      },

      msgText:        '',
      msgTextInvalid: false,
      msgTextError:   null,
      msgValid:       false,
    };
  },
  watch: {
    msgText: function (text) {
      this.msg.text = text;

      var validationResult = this.validate(text, 'required');

      if (typeof validationResult == 'string' && validationResult.length > 0)
        this.msgTextError = validationResult;
      else
        this.msgTextError = '';
      
      this.msgTextInvalid = this.msgTextError.length > 0;
    },
    msg: {
      handler: function (msg) {
        if (msg.queue) {
          sel('#Dest').value = msg.queue;
          sel('#Dest').dispatchEvent(new Event('change'));
        }

        if (msg.service) {
          sel('#ServiceID').value = msg.service;
          sel('#ServiceID').dispatchEvent(new Event('change'));
        }

        this.msgValid =
          (this.validate(msg.queue,   this.validateQueue) === true) &&
          (this.validate(msg.subject, 'required') === true) &&
          (this.validate(msg.text,    'required') === true);
      },
      deep: true
    }
  },
  methods: {
    // Validate a value 
    validate: function (value, options, args) {
      if (options == 'required')
        if (value.trim().length == 0)
          return Core.Language.Translate('This field is required');

      if (typeof options == 'function') {
        var result = options.call(this, value, args);

        if (result !== true)
          return Core.Language.Translate(result);
      }
      
      return true;
    },

    // Helper to return a validation function bound to the component
    val: function (options, args) {
      return (function (value) {
        return this.validate(value, options, args);
      }).bind(this);
    },

    validateQueue: function (queue) {
      // Queue is valid if the selected value starts with an ID
      if (parseInt(queue))
        return true;
      
      return 'This field is required';
    },

    validateType: function (type) {
      var label    = sel('#cmt-hide-original-ui label[for="TypeID"]');
      var required = label.classList.contains('Mandatory');

      if (!required)
        return true;
      
      if (parseInt(type))
        return true;
      
      return 'This field is required';
    },

    validateService: function (service) {
      var label    = sel('#cmt-hide-original-ui label[for="ServiceID"]');
      var required = label.classList.contains('Mandatory');

      if (!required)
        return true;
      
      if (parseInt(service))
        return true;
      
      return 'This field is required';
    },

    validateSLA: function (service) {// FIXME: service -> SLA?
      var label    = sel('#cmt-hide-original-ui label[for="SLAID"]');
      var required = label.classList.contains('Mandatory');

      if (!required)
        return true;
      
      if (parseInt(service))
        return true;
      
      return 'This field is required';
    },

    validateDynamicField: function (value, options) {
      var field = options.field;

      var label    = sel('label', field.row);
      var required = label.classList.contains('Mandatory');

      if (!required)
        return true;

      if (value.length)
        return true;

      return 'This field is required';
    },

    submitMsg: function () {
      // Copy entered values to original form
      sel('#Dest').value                 = this.msg.queue;
      sel('#Subject').value              = this.msg.subject;
      sel('textarea[name="Body"]').value = this.msg.text;

      var origPriority = sel('#PriorityID');
      if (origPriority)
        origPriority.value = this.msg.priority;
      
      var origType = sel('#TypeID');
      if (origType)
        origType.value = this.msg.type;
      
      var origService = sel('#ServiceID');
      var origSla     = sel('#SLAID');
      if (origService)
        origService.value = this.msg.service;
      if (origSla)
        origSla.value = this.msg.sla;

      // Populate original dynamic field inputs
      Object.keys(this.msg.dynamicFields).forEach(function (name) {
        var field = this.dynamicFields.find(function (field) {
          return field.name == name;
        });
        
        // Exclude date/time fields (the component takes care of them)
        if (field && field.type == 'date')
          return;

        var origInput = sel('[name="DynamicField_' + name + '"]');
        var value = this.msg.dynamicFields[name];
        
        if (value instanceof Array)
          selAll('option', origInput).forEach(function (option) {
            option.selected = value.includes(option.value);
          });
        else if (origInput.type !== undefined && origInput.type == 'checkbox')
          origInput.checked = !!this.msg.dynamicFields[name];
        else
          origInput.value = this.msg.dynamicFields[name];
      }, this);

      sel('#NewCustomerTicket button[type="submit"]').click();
    },

    refreshServices: function () {
      selAll('#ServiceID option').forEach(function (element) {
        this.services.push({
          value: element.value,
          name:  element.label || element.textContent,
        });

        // if (element.selected)
        //   this.msg.service = element.value;
      }, this);

      this.refreshSLA();
    },

    refreshSLA: function () {
      selAll('#SLAID option').forEach(function (element) {
        this.sla.push({
          value: element.value,
          name:  element.label || element.textContent,
        });

        // if (element.selected)
        //   this.msg.sla = element.value;
      }, this);
    },

    recognizeFieldType: function (row) {
      var name = row.classList[1] ?
        row.classList[1].replace(/^Row_DynamicField_/, '') : null;
      var type;

      if (name && (sel('select#DynamicField_' + name + 'Day') ||
          sel('select#DynamicField_' + name + 'Month') ||
          sel('select#DynamicField_' + name + 'Year')))
        type = 'date';
      else if (sel('input.DynamicFieldText', row))
        type = 'text';
      else if (sel('textarea.DynamicFieldTextArea', row))
        type = 'textarea';
      else if (sel('select.DynamicFieldText', row)) {
        if (sel('select.DynamicFieldText', row).multiple)
          type = 'multiselect';
        else
          type = 'dropdown';
      }
      else if (sel('input.DynamicFieldCheckbox'))
        type = 'checkbox';

      return type;
    },

    // CKEditor ready event handler
    onEditorReady: function () {
      sel('.cke_button__textcolor').addEventListener('click', function () {
        // Observer function to track text color selection and change the color
        // of the little bar below the toolbar icon
        var initObserver = function () {
          // Find the dropdown element that is used to display text color
          // selection
          var textColorBlock;
  
          selAll('.cke_panel iframe').forEach(function (element) {
            // Do nothing if the element has already been found
            if (textColorBlock !== undefined)
              return;
      
            textColorBlock = sel('.cke_colorblock', element.contentDocument);
          });

          // If not found, try again in 100ms
          if (textColorBlock === undefined) {
            setTimeout(initObserver, 100);
            return;
          }

          var colorAuto = sel('.cke_colorauto', textColorBlock);

          // Same as with textColorBlock
          if (colorAuto === undefined) {
            setTimeout(initObserver, 100);
            return;
          }

          // Track the clicks on "automatic" color option
          colorAuto.addEventListener('click', function (event) {
            event.currentTarget.dataset.selected = true;
          });

          (new MutationObserver(function () {
            // Check if a color is selected (the currently selected color has
            // the "cke_colorlast" attribute set to "true")
            var colorItem =
              sel('a.cke_colorbox[cke_colorlast="true"]', textColorBlock);
  
            if (colorItem)
              sel('.cke_button__textcolor').style.color = '#' +
                colorItem.dataset.value;
            else {
              // If no color was found, check the "automatic" option
              if (colorAuto.dataset.selected) {
                sel('.cke_button__textcolor').style.color =
                  sel('.cke_colorbox', colorAuto).style.backgroundColor;
                
                delete colorAuto.dataset.selected;
              }
            }            
          })).observe(textColorBlock, { attributes: true, subtree: true });
        };

        initObserver();
      }, { once: true });
    },
  },
  created: function () {
    // Get selectable queues
    selAll('#Dest option').forEach(function (element) {
      this.queues.push({
        value: element.value,
        name:  element.label || element.textContent
      });
    }, this);

    // Get priority colors and additional data from hidden inputs
    this.priorityColors =
      JSON.parse(sel('input[name="cmt.Data.PriorityColorsJSON"]').value);
    this.additionalData =
      JSON.parse(sel('input[name="cmt.Data.AdditionalDataJSON"]').value);

    this.editorConfig = {
      customConfig: '',
      language: this.additionalData['UserLanguage'],
      defaultLanguage: this.additionalData['UserLanguage'],
      removePlugins: 'elementspath,autogrow,bbcode,devtools,divarea,' +
        'embed,flash,mathjax,stylesheetparser,image,' +
        'exportpdf,magicline',
      toolbar: [
        {
          name: 'basicstyles',
          items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'TextColor' ]
        },
        {
          name: 'styles',
          items: [ 'Format' ]
        },
        {
          name: 'paragraph',
          items: [ 'JustifyLeft', 'JustifyCenter', 'JustifyRight',
            'JustifyBlock' ]
        },
        {
          name: 'paragraph',
          items: [ 'BulletedList', 'NumberedList' ]
        }
      ],
      resize_enabled: true,
      resize_minHeight: 100,
      height: 200,

      extraAllowedContent: 'div[type]{*}; img[*]; col[width]; style[*]{*}; *[id](*)',
      filebrowserUploadUrl: 
        this.additionalData['Baselink'] +
          'Action=' + this.additionalData['RichText.PictureUploadAction'] + '&' +
          'FormID=' + sel('input[name="FormID"]', sel('#Dest').form).value + '&' +
          this.additionalData['SessionName'] + '=' +
            this.additionalData['SessionID']
    };

    selAll('#PriorityID option').forEach(function (element) {
      this.priorities.push({
        value: element.value,
        name:  element.label || element.textContent,
        color: this.priorityColors[element.value]
      });

      if (element.selected)
        this.msg.priority = element.value;
    }, this);

    selAll('#TypeID option').forEach(function (element) {
      this.types.push({
        value: element.value,
        name:  element.label || element.textContent
      });

      if (element.selected)
        this.msg.type = element.value;
    }, this);

    this.refreshServices();

    // Set the pre-selected queue
    this.msg.queue = sel('#Dest').value;

    // Set the existing subject
    this.msg.subject = sel('#Subject').value;

    selAll('.Row[class^="Row Row_DynamicField_"]').forEach(function (row) {
      var name, type, label, options, value, serverError;

      type = this.recognizeFieldType(row);
      
      if (type == 'text') {
        name  = sel('.Field input', row).name;
        value = sel('.Field input', row).value;
      }
      else if (type == 'textarea') {
        name  = sel('.Field textarea', row).name;
        value = sel('.Field textarea', row).value;
      }
      else if (type == 'dropdown') {
        name  = sel('.Field select', row).name;
        value = sel('.Field select', row).value;
        
        options = [];
        Array.from(selAll('.Field select option', row)).map(function (option) {
          options.push({
            name:  option.textContent,
            value: option.value
          });
        });
      }
      else if (type == 'multiselect') {
        var select = sel('.Field select', row);      
        
        name  = select.name;
        value = [];

        options = [];
        Array.from(selAll('option', select)).forEach(function (option) {
          options.push({
            name:  option.textContent,
            value: option.value
          });

          if (option.selected)
            value.push(option.value);
        });
      }
      else if (type == 'date') {
        name = row.classList[1].replace(/^Row_/, '');
      }
      else if (type == 'checkbox') {
        name  = sel('input[type="checkbox"]', row).name;
        value = sel('input[type="checkbox"]', row).checked;
      }

      name = name.replace(/^DynamicField_/, '');

      sel('label', row).childNodes.forEach(function (node) {
        if (node.nodeType == Node.TEXT_NODE)
          label = node.textContent;
      });

      var serverErrorDiv = sel('#DynamicField_' + name + 'ServerError', row);
      
      if (serverErrorDiv) {
        serverError = sel('p', serverErrorDiv).textContent.trim();
      }

      this.dynamicFields.push({
        name:  name,
        type:  type,
        label: label.trim().replace(/:$/, ''),
        value: value,

        options: options,

        serverError: serverError,

        row:         row,
        errorAttach: null
      });

      this.msg.dynamicFields[name] = value;
    }, this);
  },
  mounted: function () {
    // Recreate the original action of the "print" icon
    $('#cmt-ticket-print').on('click', function () {
      Core.UI.Popup.OpenPopup($(this).attr('href'), 'TicketAction');
      return false;
    });

    sel('.message .attachments').addEventListener('dragover', function (event) {
      event.currentTarget.classList.add('drag-over');
      event.preventDefault();
    })

    sel('.message .attachments').addEventListener('dragend', function (event) {
      event.currentTarget.classList.remove('drag-over');
      event.preventDefault();
    })

    sel('.message .attachments').addEventListener('dragleave', function (event) {
      event.currentTarget.classList.remove('drag-over');
      event.preventDefault();
    })

    sel('.message .attachments').addEventListener('drop', function (event) {
      event.currentTarget.classList.remove('drag-over');
      event.preventDefault();

      // Create a duplicate of the event and dispatch it on the original
      // drag-and-drop upload element

      var dragEvent = new DragEvent('drop');
      
      Object.defineProperty(dragEvent, 'dataTransfer', {
        value: event.dataTransfer
      });
      
      dragEvent.type      = 'drop';
      dragEvent.isTrusted = true;
      dragEvent.target    = sel('.DnDUpload');
      
      sel('.DnDUpload').dispatchEvent(dragEvent);
    });

    var origUploadBox = sel('.DnDUploadBox');

    // Observer the changes to the original attachment table and recreate
    // the complete list in the new UI whenever there's a change
    (new MutationObserver((function () {
      this.msg.attachments = []

      selAll('.AttachmentList tbody tr', origUploadBox).forEach(
        function (element) {
          this.msg.attachments.push({
            fileName:    sel('td.Filename', element).textContent,
            fileSize:    sel('td.Filesize', element).textContent,
            fileSizeRaw: sel('td.Filesize', element).dataset.fileSize,
            type:        sel('td.Filetype', element).textContent,
                      
            deleteElement: sel('td .AttachmentDelete', element),
          })
        }, this);
    }).bind(this))).observe(origUploadBox, { childList: true, subtree: true });

    (new MutationObserver(this.refreshServices)).observe(sel('#ServiceID'), {
      childList: true,
      subtree: true
    });

    this.dynamicFields.forEach(function (field) {
      var fieldElement = document.querySelector('#df_' + field.name);

      if (!fieldElement)
        return;

      field.errorAttach =
        fieldElement.parentElement.parentElement.parentElement;
    });
  }
}
</script>

<style scoped>
h2 {
  font-size: 135%;
}

.v-form fieldset {
  background: initial;
  margin: initial;
  padding: initial;
}

.v-form legend {
  display: initial;
}

.v-form label {
  display: inline-block;
  margin-right: initial;
  float: initial;
  font-size: initial;
  padding: initial;
  text-align: initial;
  width: initial;
}

.v-form label.above {
  display: inline-block;
}

.v-form .v-input__slot input[type="text"] {
  border: initial;
  border-radius: initial;
  height: initial;
  padding: initial;
}

.v-form input[type="text"]:focus {
  box-shadow: initial;
}

.v-form .v-select .v-list-item .v-list-item.select-item {
  font-size: initial;
  font-weight: initial;
}

.v-form .tooltip-error .v-input__slot,
.v-form .tooltip-error .v-text-field__details {
  margin-bottom: 0;
}

.v-form .tooltip-error .v-text-field__details,
.v-form .tooltip-error .v-messages {
  min-height: auto;
  overflow: visible;
}

.v-form .tooltip-error .v-tooltip__content.error {
  left: 50% !important;
  top: 110% !important;
  transform: translateX(-50%);
  /* These two rules should be added by the .error class, but for some reason
     they aren't */
  background-color: #ff5252 !important;
  border-color: #ff5252 !important;
}

.v-form .tooltip-error .v-tooltip__content::before {
  background-color: inherit;
  content: "";
  clip-path: polygon(0% 0%, 100% 0%, 0% 100%);    
  display: inline-block;
  height: 20px;
  left: 50%;
  position: absolute;
  rotate: 45deg;  
  transform: translateX(-50%) translateY(-50%);
  transform-origin: top left;
  width: 20px;
}

.v-form .cmt-ckeditor {
  position: relative;
}

.v-form .cmt-ckeditor .v-tooltip__content.error {
  bottom: -5px;
  top: auto !important;
  transform: translateX(-50%) translateY(100%);
}

.v-form input[readonly] {
  background-color: initial;
}

.cmt-ckeditor .cke_editable {
  height: 10rem;
}

.message .row:last-child {
  margin-bottom: 0;
}

.message .attachments {
  background: rgb(244, 246, 248);
  border: solid 1px rgba(0, 0, 0, 0.38);
  border-radius: 4px;
  min-height: 4rem;
  transition: all 0.25s ease-in-out;
}

.message .attachments.drag-over {
  background: rgb(33, 150, 243, 0.25);
}

.message .attachments .hint p {
  font-size: initial;
}

.message .attachments .hint,
.message .attachments .hint p,
.message .attachments .hint .v-icon {
  color: rgba(0, 0, 0, 0.2);
  user-select: none;
}

.message .attachments .hint .v-icon {
  font-size: 200%;
}

.message .v-btn {
  font-size: initial;
  letter-spacing: 0.025em;
  text-transform: none;
}
</style>

<style>
.v-select-list .v-list-item--active {
  background-color: rgba(33, 150, 243, 0.15);
}

.v-select-list .v-list-item--active::before {
  opacity: 0;
  visibility: hidden;
}

.v-list-item .priority-color,
.v-select__selections .priority-color {
  border-bottom: solid 2px rgba(0,0,0,0.2);
  border-radius: 0.2em;
  display: inline-block;
  height: 100%;
  line-height: 1;
  margin-right: 0.8rem;
  width: 1.2rem;
}
</style>

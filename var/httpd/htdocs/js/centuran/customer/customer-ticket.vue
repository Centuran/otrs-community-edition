<template>
  <v-container>
    <v-row>
      <v-col cols="12" md="9">
        <div class="TicketHeader">
          <h2 :title="ticket.title">
            <div 
              v-if="ticket.priority !== null"
              class="Flag" :title="ticket.priority">
              <span
                :class="`PriorityID-${ticket.priorityId}`"
                :style="`background-color: ${priorityColors[ticket.priorityId]};`"
              >
                {{ ticket.priority }}
              </span>
            </div>

            {{ ticket.title }}
          </h2>
        </div>

        <!-- Expand/collapse and print icons -->
        <v-sheet align="right" color="transparent">
          <v-btn
            icon
            color="white--darken-1"
            :title="Core.Language.Translate('Expand all articles')"
            @click="articles.forEach(article => article.expanded = true)"
          >
            <v-icon color="grey">mdi-expand-all</v-icon>
          </v-btn>

          <v-btn 
            icon
            color="white--darken-1"
            :title="Core.Language.Translate('Collapse all articles')"
            @click="articles.forEach(article => article.expanded = false)"
            class="ml-2"
          >
            <v-icon color="grey">mdi-collapse-all</v-icon>
          </v-btn>

          <v-divider vertical></v-divider>

          <v-btn v-if="ticket.printUrl"
            id="cmt-ticket-print"
            icon
            color="white--darken-1"
            :title="Core.Language.Translate('Print')"
            :href="ticket.printUrl"
            class="ml-4"
          >
            <v-icon color="grey">mdi-printer</v-icon>
          </v-btn>
        </v-sheet>

        <v-timeline light dense align-top>

          <v-timeline-item light
            v-for="(article, i) in articles"
            :id="`article-${article.id}`"
            :key="i"
            large
            :icon="article.icon"
            :data-id="article.id"
            :class="`article ${article.sentByUser ? 'article-user' : ''} pt-6 mb-2`"
          >
            <template v-slot:icon>
              <v-avatar>
                <img :src="article.gravatarUrl"/>
              </v-avatar>
            </template>

            <div class="sender-date pl-4 text--secondary">
              <span class="font-weight-medium">
                {{ article.fromName }}
              </span>
              <span class="date text--disabled ml-4" :title="article.dateTime">
                {{ article.dateTimeRelative }}
              </span>
            </div>

            <v-card 
              elevation="2"
              :ripple="false"
              :link="false"
              @click="(event) => { if (!article.expanded) article.expanded = true; event.stopPropagation(); }"
              :class="article.senderType == 'customer' ? 'customer' : ''"
            >
              <v-card-text>
                <div class="title mb-4 font-weight-medium text--primary">
                  {{ article.title }}
                </div>

                <v-btn
                  elevation="0"
                  icon
                  @click.stop="article.expanded = !article.expanded"
                  class="toggle"
                  :title="article.expanded  ?
                    `${Core.Language.Translate('Collapse article')}` :
                    `${Core.Language.Translate('Expand article')}`"
                >
                  <v-icon v-if="article.expanded">mdi-minus-box</v-icon>
                  <v-icon v-else="article.expanded">mdi-plus-box</v-icon>
                </v-btn>

                <div
                  class="content"
                  :style="`height: ${contentHeight(article)};`"
                >
                  <iframe class="content-frame" style="height: 0;"></iframe>

                  <div v-if="article.attachments.length > 0" class="mt-4">
                    <v-divider class="mb-2"></v-divider>

                    <table class="attachments">
                      <tbody>
                        <th
                          v-html="`${Core.Language.Translate('Attachments')}:`"
                          class="pr-4"
                        ></th>
                        <td>
                          <v-chip v-for="(attachment, i) in article.attachments"
                            class="ml-2 mt-2"
                            color="rgb(224, 224, 224)"
                            :href="attachment.url"
                          >
                            <v-icon left>
                              mdi-attachment
                            </v-icon>
                            {{ attachment.fileName }}
                            <span class="size text--disabled pl-1">
                              ({{attachment.fileSize }})
                            </span>
                          </v-chip>
                        </td>
                      </tbody>
                    </table>
                  </div>
                </div>
              </v-card-text>
            </v-card>
          </v-timeline-item>

          <v-timeline-item v-if="replyFormPresent"
            hide-dot
          >
            <v-divider 
              width="50%"
              align="center"
              class="end mx-auto my-6"
            ></v-divider>
          </v-timeline-item>

          <v-timeline-item v-if="replyFormPresent"
            light
            class="reply article-user pt-6 mb-2"
            large
          >
            <template v-slot:icon>
              <v-avatar>
                <img :src="customerUser.gravatarUrl"/>
              </v-avatar>
            </template>

            <div class="sender-date pl-4 text--secondary">
              <span class="font-weight-medium">
                {{ customerUser.fullName }}
              </span>
            </div>

            <v-card>
              <v-card-text>
                <v-form>
                  <v-container class="pa-0">
                    <v-row class="ma-0 pa-0">
                      <v-col class="pa-0 d-flex align-baseline">
                        <label
                          v-html="`${Core.Language.Translate('Subject')}:`"
                          class="mr-4"
                        ></label>
                        <v-text-field
                          id="reply_subject"
                          v-model="reply.subject"
                          dense
                          outlined
                          :rules="[ val('required') ]"
                          class="tooltip-error"
                        >
                          <template v-slot:message="{ message }">
                            <v-tooltip bottom
                              :attach="document.querySelector('#reply_subject').parentElement.parentElement.parentElement"
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
                    <v-row class="my-0">
                      <v-col class="py-0">
                        <label
                          v-html="`${Core.Language.Translate('Text')}:`"
                          class="above mb-1 mt-4"
                        ></label>
                        <ckeditor
                          v-model="replyText"
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
                          v-model="replyTextInvalid"
                        >
                          <span>{{ replyTextError }}</span>
                        </v-tooltip>

                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col class="py-0">
                        <label
                          v-html="`${Core.Language.Translate('Attachments')}:`"
                          class="above mb-1 mt-1"
                        ></label>
                        <div class="attachments"
                          @click="document.querySelector('.DnDUpload').click()"
                        >
                          <div v-if="reply.attachments.length > 0">
                            <v-chip v-for="(attachment, i) in reply.attachments"
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
                    <v-row v-if="states.length || priorities.length">
                      <v-col v-if="states.length" cols="12" md="6" class="pb-0">
                        <label
                          v-html="`${Core.Language.Translate('Set state to')}:`"
                          class="above mb-1"
                        ></label>
                        <v-select
                          v-model="reply.state"
                          dense
                          outlined
                          :items="states"
                          item-text="name"
                          item-value="value"
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
                        </v-select>
                      </v-col>
                      <v-col v-if="priorities.length" cols="12" md="6" class="pb-0">
                        <label
                          v-html="`${Core.Language.Translate('Set priority to')}:`"
                          class="above mb-1"
                        ></label>
                        <v-select
                          v-model="reply.priority"
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
                  </v-container>
                </v-form>
              </v-card-text>
            </v-card>

            <div class="mt-6 text-right pr-6">
              <v-btn
                v-if="closingStateId"
                large
                color="white"
                class="text--secondary px-8 mr-6"
                @click="reply.state = closingStateId; submitReply();"
                :disabled="!replyValid"
                v-html="`${Core.Language.Translate('Reply and Close')}`"
              ></v-btn>

              <v-btn
                large
                color="rgb(33, 150, 243)"
                class="font-weight-medium px-8 white--text"
                @click="submitReply()"
                :disabled="!replyValid"
                v-html="`${Core.Language.Translate('Reply')}`"
              ></v-btn>
            </div>
          </v-timeline-item>
        </v-timeline>
      </v-col>

      <v-col cols="12" md="3">
        <v-card
          class="mb-8"
        >
          <v-card-title
            v-html="Core.Language.Translate('Ticket Information')"
          ></v-card-title>
          <v-card-text>
            <v-simple-table class="ticket-data">
              <template v-slot:default>
                <tbody>
                  <tr v-for="item in ticket.metaData">
                    <th>{{ item.title }}</th>
                    <td>
                      <span v-if="item.title == Core.Language.Translate('Priority')"
                        class="priority-color"
                        :style="`background: ${priorityColors[ticket.priorityId]}`"
                      >&nbsp;</span>
                      
                      {{ item.value }}
                    </td>
                  </tr>
                </tbody>
              </template>
            </v-simple-table>
          </v-card-text>
        </v-card>

        <v-card v-if="ticket.isProcess"
          class="process-activities"
        >
          <v-card-title
            v-html="Core.Language.Translate('Next Steps')"
          ></v-card-title>
          <v-card-text>
            <v-btn v-for="(item, index) in ticket.nextActivities"
              tag="a"
              :href="item.href"
              block
              depressed
              color="rgb(33, 150, 243)"
              :class="`AsPopup process-activity white--text py-2
                ${index > 0 ? 'mt-4' : ''}`"
            >
              <span class="text-center">
                {{ item.title }}
              </span>
            </v-btn>

            <p v-if="ticket.nextActivities.length == 0"
              class="text-center"
            >
              {{ 
                Core.Language.Translate('There are no dialogs available at ' +
                  'this point in the process.')
              }}
            </p>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-btn
      fab
      fixed
      bottom
      right
      dark
      color="rgb(33, 150, 243)"
      :title="`${Core.Language.Translate('Reply')}`"
      @click="$vuetify.goTo('.reply')"
    >
      <v-icon>mdi-reply</v-icon>
    </v-btn>
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

// Helper method to translate a length property into number of pixels
// (very basic, currently only able to handle "em", assuming 1em == 16px)
function px(value) {
  if (!value || value == 'auto')
    return 0;

  if (value.toString().endsWith('px'))
    return parseInt(value);
  
  if (value.toString().endsWith('em'))
    return Math.round(parseFloat(value) * 16);
  
  return parseInt(value);
}

function gravatarUrl(emailHash) {
  return '//www.gravatar.com/avatar/' + emailHash + '?s=80&d=mp';
}

module.exports = {
  props: {
    ticketId: Number,
  },
  data: function () {
    return {
      editorConfig: {
        customConfig: '',
        language: Core.Config.Get('UserLanguage'),
        defaultLanguage: Core.Config.Get('UserLanguage'),
        removePlugins: 'elementspath,autogrow,bbcode,devtools,divarea,' +
          'embed,flash,mathjax,stylesheetparser,image,uploadimage,uploadfile,' +
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
              'JustifyBlock']
          },
          {
            name: 'paragraph',
            items: [ 'BulletedList', 'NumberedList' ]
          }
        ],
        resize_enabled: true,
        resize_minHeight: 100,
        height: 200,
      },
      customerUser: {},
      ticket: {},
      articles: [],
      closedStates: [],           // IDs of states of the type "closed"
      priorityColors: {},
      priorities: [],
      states: [],
      reply: {
        subject: '',
        text: '',
        state: '',
        priority: '',
        attachments: []
      },
      replyFormPresent: true,
      replyText: '',
      replyTextInvalid: false,
      replyTextError: '',
      closingStateId: null,       // ID of the state set on "Reply and Close"
      replyValid: false,
    };
  },
  watch: {
    replyText: function (text) {
      this.reply.text = text;

      var validationResult = this.validate(text, 'required');

      if (typeof validationResult == 'string' && validationResult.length > 0)
        this.replyTextError = validationResult;
      else
        this.replyTextError = '';
      
      this.replyTextInvalid = this.replyTextError.length > 0;
    },
    reply: {
      handler: function (reply) {
        this.replyValid =
          (this.validate(reply.subject, 'required') === true) &&
          (this.validate(reply.text,    'required') === true);
      },
      deep: true
    }
  },
  methods: {
    // Calculate expanded article content height
    contentHeight: function (article) {
      if (!article.loaded)
        return 'auto';

      if (!article.expanded)
        return '0px';

      var content = sel(`#article-${article.id} .content`);
      var height  = 0;

      var element = content.firstElementChild;

      while (element) {
        var style = window.getComputedStyle(element);
        height += element.offsetHeight + px(style.marginTop) +
          px(style.marginBottom);
          
        element = element.nextElementSibling;
      }

      return height.toString() + 'px';
    },

    // Validate a value 
    validate: function (value, options) {
      if (options == 'required')
        if (value.trim().length == 0)
          return Core.Language.Translate('This field is required');
      
      return true;
    },

    // Helper to return a validation function bound to the component
    val: function (options) {
      return (function (value) {
        return this.validate(value, options);
      }).bind(this);
    },

    submitReply: function () {
      // Copy entered values to original form
      sel('#Subject').value              = this.reply.subject;
      sel('textarea[name="Body"]').value = this.replyText;
      
      var origState = sel('#StateID');
      if (origState)
        origState.value = this.reply.state;

      var origPriority = sel('#PriorityID');
      if (origPriority)
        origPriority.value = this.reply.priority;
      
      sel('#ReplyCustomerTicket button[type="submit"]').click();
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
    var userLanguage     = sel('input[name="cmt.Data.UserLanguage"]').value;
    var userFullname     = sel('input[name="cmt.Data.UserFullname"]').value;
    var userEmailAddress = sel('input[name="cmt.Data.UserEmailAddress"]').value;
    var userEmailMd5Hash = sel('input[name="cmt.Data.UserEmailMD5Hash"]').value;

    userLanguage ||= 'en';

    this.customerUser = {
      fullName:    userFullname,
      gravatarUrl: gravatarUrl(userEmailMd5Hash)
    };

    var origArticlesHTML = sel('#Messages').innerHTML;

    var container = document.createElement('div');
  
    container.innerHTML = origArticlesHTML;

    var title = sel('.TicketHeader > h2').getAttribute('title');

    var priority   = null;
    var priorityId = null;
    
    var priorityIndicator = sel('.TicketHeader > h2 .Flag');

    if (priorityIndicator) {
      var priorityClass = sel('span', priorityIndicator).getAttribute('class');
      
      priority   = priorityIndicator.getAttribute('title');
      priorityId = priorityClass.replace(/^PriorityID-/, '');
    }

    var metaData = [];

    selAll('#Metadata li').forEach(function (element) {
      if (element.className == 'Header')
        return true;
      
      metaData.push({
        title: sel('span', element).textContent.replace(/:$/, ''),
        value: sel('span', element).nextElementSibling.textContent,
      });
    });

    var isProcessTicket = sel('#Activities') !== null;
    var nextActivities  = [];

    selAll('#Activities li').forEach(function (element) {
      if (element.className == 'Header')
        return true;

      if (!sel('a', element))
        return true;
      
      nextActivities.push({
        title: sel('a', element).getAttribute('title'),
        href:  sel('a', element).getAttribute('href'),
      });
    });
    
    var printLink =
      sel('#TicketOptions a[href*="Action=CustomerTicketPrint;"]');
    var printUrl = printLink ? printLink.getAttribute('href') : null;

    this.ticket = {
      title:          title,
      priority:       priority,
      priorityId:     priorityId,
      metaData:       metaData,
      isProcess:      isProcessTicket,
      nextActivities: nextActivities,
      printUrl:       printUrl,
    };

    for (var item of container.children) {
      var senderType = item.getAttribute('class').match(/^(.*?)-[01] ?/)[1];
      
      var header   = sel('.MessageHeader', item);
      var title    = sel('h3 a span', header).textContent.trim();
      var dateTime = sel('.Age', header).getAttribute('title');

      // Assume the "From" field is the first one in the details
      // (to have a fallback if for whatever reason we can't find it by content
      // in the forEach below)
      var fromLabel = selAll('.Details .Label', item).item(0);
      
      selAll('.Details .Label', item).forEach(function (element) {
        if (element.textContent == Core.Language.Translate('From') + ':')
          return !(fromLabel = element);
      });

      var fromName = fromLabel.nextElementSibling.textContent;
      fromName = fromName.replace(/^"(.*)"$/, '$1');

      var articleId = sel('input[name="cmt.Data.ArticleID"]', item).value;

      // Set global Day.js locale (NOTE: we also do this in common JS
      // in CustomerFooter, but it gets called later, so it's repeated here.
      // Plus, Core.Config.Get('UserLanguage') is not yet set here, so we get
      // the language from page contents. Anyway, should probably DRY it up.)
      dayjs.locale(userLanguage.replace('_', '-'));

      dayjs.extend(window.dayjs_plugin_relativeTime);

      var dateNow = dayjs();

      var timestamp = sel('input[name="cmt.Data.IncomingTime"]', item).value;

      var date = dayjs.unix(timestamp);

      var dateTimeRelative = date.from(dateNow);

      var dataFrom = sel('input[name="cmt.Data.From"]', item).value;
      var fromAddress = dataFrom.replace(/^.*<|>$/g, '');

      var fromMd5Hash = sel('input[name="cmt.Data.FromMD5Hash"]', item).value;

      var attachments = []

      selAll('.Attachments .DownloadAttachment', item).forEach(
        function (element) {
          var fileLink = sel('a', element);
          
          var fileSize = fileLink.nextSibling.textContent.trim();
          // Get rid of brackets around file size
          fileSize = fileSize.replace(/^\(|\)$/g, '');

          attachments.push({
            fileName: fileLink.textContent,
            fileSize: fileSize,
            url:      fileLink.getAttribute('href')
          });
        });

      var sentByUser = fromAddress == userEmailAddress;

      // Assemble all article data into a single object
      var article = {
        id: articleId,

        item: item,

        senderType: senderType,
        sentByUser: sentByUser,

        title:      title,
        content:    null,

        dateTime:         dateTime,
        dateTimeRelative: dateTimeRelative,
        
        fromName:    fromName,
        fromAddress: fromAddress,
        
        gravatarUrl: gravatarUrl(fromMd5Hash),
        
        icon: sentByUser ? 'mdi-arrow-up' : 'mdi-arrow-down',

        attachments: attachments,

        loaded:   false,
        expanded: true,
      };

      var setContent = function (article, content) {
        article.content = content;

        var iframe = sel('#article-' + article.id + ' .content-frame');

        iframe.contentWindow.document.open();
        iframe.contentWindow.document.write(article.content);
        iframe.contentWindow.document.close();

        // Copy font size from parent document
        iframe.contentWindow.document.body.style.fontSize =
          getComputedStyle(document.body).fontSize;

        // Most suggestions for adjusting iframe height to match contents
        // seem to favor contentWindow.document.body.scrollHeight,
        // but that resulted in additional vertical margin for some reason.
        iframe.style.height =
          iframe.contentWindow.document.documentElement.offsetHeight + 'px';

        // Reset body margins
        iframe.contentWindow.document.head.innerHTML =
          '<style type="text/css">body { margin: 0; }</style>' +
          iframe.contentWindow.document.head.innerHTML;

        article.loaded = true;
      };

      var contentIframe = sel('.MessageBody iframe', item);
      
      if (contentIframe) {
        var contentSrc = contentIframe.getAttribute('src');
      
        if (contentSrc == 'about:blank')
          // The URL to fetch the source is in the "title" attribute
          // (some OTRS shenenigans with the iframe)
          contentSrc = contentIframe.getAttribute('title');

        fetch(contentSrc)
          .then(function (response) {
            return response.text();
          })
          .then((function (text) {
            var article = this.article;

            setContent(article, text);
            sel(`#article-${article.id} .content`).style.height =
              this.contentHeight(article);
          }).bind({ contentHeight: this.contentHeight, article: article }));
      }
      else {
        // Content is placed directly in the article item (not in an iframe)
        setTimeout((function () {
          var article = this.article;
          var item    = article.item;
          var content = sel('.MessageBody .ArticleBody', item).innerHTML;

          setContent(article, content);
          sel(`#article-${article.id} .content`).style.height =
            this.contentHeight(article);
        }).bind({ contentHeight: this.contentHeight, article: article }), 0);
      }
         
      this.articles.push(article);
    }

    this.closedStates =
      JSON.parse(sel('input[name="cmt.Data.ClosedStatesJSON"]').value);
    
    this.priorityColors =
      JSON.parse(sel('input[name="cmt.Data.PriorityColorsJSON"]').value);

    selAll('#PriorityID option').forEach(function (element) {
      this.priorities.push({
        value: element.value,
        name:  element.label || element.textContent,
        color: this.priorityColors[element.value]
      });

      if (element.selected)
        this.reply.priority = element.value;
    }, this);

    selAll('#StateID option').forEach(function (element) {
      this.states.push({
        value: element.value,
        name:  element.label || element.textContent,
      });

      if (element.selected)
        this.reply.state = element.value;
    }, this);

    var closedStates = this.states.filter(function (state) {
      return this.closedStates.includes(parseInt(state.value));
    }, this);

    // If there is just one closing state, use it for "Reply and Close"
    if (closedStates.length == 1)
      this.closingStateId = closedStates[0].value;
    // If there are more, look for the "closed successful" state and assume
    // it is the original default system state that can be used for closing
    else
      closedStates.forEach(function (state) {
        if (state.name == Core.Language.Translate('closed successful'))
          this.closingStateId = state.value;
      }, this);

    this.replyFormPresent = sel('#FollowUp') !== null;

    if (this.replyFormPresent)
      this.reply.subject = sel('#Subject').value;
  },
  mounted: function () {
    // Recreate the original action of the "print" icon
    $('#cmt-ticket-print').on('click', function () {
      Core.UI.Popup.OpenPopup($(this).attr('href'), 'TicketAction');
      return false;
    });

    if (this.replyFormPresent) {
      sel('.reply .attachments').addEventListener('dragover', function (event) {
        event.currentTarget.classList.add('drag-over');
        event.preventDefault();
      })

      sel('.reply .attachments').addEventListener('dragend', function (event) {
        event.currentTarget.classList.remove('drag-over');
        event.preventDefault();
      })

      sel('.reply .attachments').addEventListener('dragleave', function (event) {
        event.currentTarget.classList.remove('drag-over');
        event.preventDefault();
      })

      sel('.reply .attachments').addEventListener('drop', function (event) {
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

      // Observe the changes to the original attachment table and recreate
      // the complete list in the new UI whenever there's a change
      (new MutationObserver((function () {
        this.reply.attachments = []

        selAll('.AttachmentList tbody tr', origUploadBox).forEach(
          function (element) {
            this.reply.attachments.push({
              fileName:    sel('td.Filename', element).textContent,
              fileSize:    sel('td.Filesize', element).textContent,
              fileSizeRaw: sel('td.Filesize', element).dataset.fileSize,
              type:        sel('td.Filetype', element).textContent,
                        
              deleteElement: sel('td .AttachmentDelete', element),
            })
          }, this);
      }).bind(this))).observe(origUploadBox, { childList: true, subtree: true });
    }

    // Adjust the size of expanded articles when window is resized
    window.addEventListener('resize', (function () {
      this.articles.forEach(function (article) {
        if (!article.expanded)
          return;

        sel(`#article-${article.id} .content`).style.height =
          this.contentHeight(article);
      }, this)
    }).bind(this));
  }
}
</script>

<style scoped>
.TicketHeader {
  width: auto;
}

.TicketHeader h2 {
  margin: 0;
  padding: 0;
  place-items: flex-start;
}

.v-timeline {
  padding-top: 0;
}

.ticket-data table tbody tr {
  vertical-align: revert;
}

.ticket-data table tbody tr:hover {
  background-color: transparent !important;
}

.ticket-data table tbody tr th,
.ticket-data table tbody tr td {
  font-size: initial;
  padding-left: 0;
  padding-right: 0;
  vertical-align: middle;
}

.ticket-data table tbody tr th {
  font-weight: 500;
  padding-right: 0.5rem;
}

.ticket-data table tbody tr td .priority-color {
  border-bottom: solid 2px rgba(0, 0, 0, 0.2);
  border-radius: 0.2em;
  display: inline-block;
  height: 1.2em;
  line-height: 1;
  margin-right: 0.4rem;
  vertical-align: middle;
  width: 1.2rem;
}

.sender-date {
  font-size: 0.875rem;
  line-height: 24px;
  margin-bottom: 4px;
  margin-top: -24px;
}

/* These styles create the shadow under the card pointer triangle
   and should be there by default, but Vuetify insists on adding the "link"
   class to the card (because there is a "@click" attribute), which overrides
   these styles -- so we need to add them explicitly. */
.v-timeline-item .v-card:before {
  background: initial;  
  border-bottom: 10px solid transparent;
  border-right: 10px solid #000;
  border-right-color: rgba(0, 0, 0, 0.12);
  border-top: 10px solid transparent;
  bottom: auto;
  left: -10px;
  opacity: 1;
  right: auto;
  top: 12px;
  transform: rotate(0);
}

.v-card .sender {
  font-size: 0.875rem;
}

.v-card .title {
  font-size: 1.25rem;
  line-height: 1;
}

.v-card .toggle {
  display: none;
  opacity: 0.75;
  position: absolute;
  right: 1em;
  top: calc(1em - 8px);
}

.v-card:hover .toggle {
  display: initial;
}

.v-card .content {
  height: auto;
  overflow: hidden;
  transition: all 0.25s ease-in-out;
}

.v-card .content em {
  font-style: italic;
}

.v-card .content ol,
.v-card .content ul {
  list-style: initial;
}

.v-card .content .__cmt-blockquote {
  border-left: solid 0.25em #ddd !important;
  padding-left: 0.5em;
}

/* The following two rules are supposed to shift the attachment chips up
   and add a negative margin at the bottom so that there is no extra empty
   space. */
.article .attachments {
  margin-bottom: -8px;
}

.article .attachments td a.v-chip {
  position: relative;
  top: -8px;
}

.v-timeline-item:last-child .v-timeline-item__dot::after {
  background-color: rgb(234, 238, 240);
  content: '';
  height: 100%;
  left: 49%;
  margin-top: 1px;
  position: absolute;
  width: 10px;
}

.v-timeline-item .v-card .v-card__text {
  border-right: solid 8px rgb(224, 224, 224);
}

.v-timeline-item.article-user .v-card .v-card__text {
  border-right: solid 8px #2196f3;
}

.v-timeline-item.article-user .v-timeline-item__dot,
.v-timeline-item.reply .v-timeline-item__dot {
  background-color: #2196f3;
} 

.v-timeline-item .v-divider.end {
  border-top-width: 2px;
}

/* Reply form */

.v-form fieldset {
  background: initial;
  margin: initial;
  padding: initial;
}

.v-form legend {
  display: initial;
}

.v-form label {
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

.v-form input[type="text"] {
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

.reply .row:last-child {
  margin-bottom: 0;
}

.reply .attachments {
  background: rgb(244, 246, 248);
  border: solid 1px rgba(0, 0, 0, 0.38);
  border-radius: 4px;
  min-height: 4rem;
  transition: all 0.25s ease-in-out;
}

.reply .attachments.drag-over {
  background: rgb(33, 150, 243, 0.25);
}

.reply .attachments .hint p {
  font-size: initial;
}

.reply .attachments .hint,
.reply .attachments .hint p,
.reply .attachments .hint .v-icon {
  color: rgba(0, 0, 0, 0.2);
  user-select: none;
}

.reply .attachments .hint .v-icon {
  font-size: 200%;
}

.reply .v-btn {
  font-size: initial;
  letter-spacing: 0.022em;
  text-transform: none;
}

.process-activities p {
  font-size: initial;
}

.v-btn.process-activity {
  font-size: initial;
  height: fit-content;
  letter-spacing: 0.022em;
  text-transform: none;
}

.v-btn.process-activity .v-btn__content {
  flex: auto;
  white-space: normal;
}
</style>

<style>
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

/* Hide original UI */

#MainBox > .Content > .TicketHeader {
  display: none;
}
</style>

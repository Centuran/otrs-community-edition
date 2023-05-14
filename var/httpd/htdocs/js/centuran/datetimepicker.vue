<!-- TODO: make colors styleable with theme CSS -->
<template>
  <div class="cmt-datetimepicker">
    <v-menu v-if="showDate"
        ref="menuDate" eager bottom offset-overflow offset-y
        :content-class="`menu-pointing ${menuClasses.menuDate}`"
        @input="updateClasses('menuDate')">
      <template v-slot:activator="{ on, attrs }">
        <input ref="dateInput" type="text" v-model="date.displayed" v-on="on"
          class="dateTimePicker-dateInput" />
      </template>
      <v-date-picker
        v-model="date.picked"
        :color="color"
        :no-title="true"
        :allowed-dates="allowedDates"
        @click.native.stop
        @input="$refs.menuDate.isActive = false"
      ></v-date-picker>
      <!-- TODO: Add "Today" button in default slot -->
    </v-menu>
    <v-menu v-if="showTime"
        ref="menuTime"
        v-model="timeMenuIsOpen"
        eager bottom offset-overflow offset-y
        :close-on-content-click="false"
        :content-class="`menu-pointing ${menuClasses.menuTime}`"
        @input="updateClasses('menuTime')">
      <template v-slot:activator="{ on, attrs }">
        <input ref="timeInput" type="text" v-model="time.picked" v-on="on"
          class="dateTimePicker-timeInput" />
      </template>
      <!-- TODO: Use 12/24-hour format, depending on locale -->
      <v-time-picker
        v-if="timeMenuIsOpen"
        v-model="time.picked"
        :color="color"
        :no-title="true"
        @click.native.stop
        @click:minute="$refs.menuTime.isActive = false"
      ></v-time-picker>
    </v-menu>
  </div>
</template>

<script>
module.exports = {
  props: {
    color: {
      // default: '#f15a22',
      default: window.__use_new_customer_ui ? '#2196f3' : '#24408c'
    },
    mode: {
      default: 'date/time',
    },
    originalField: {
      type: Object,
      default: null,
    },
  },
  data: function () {
    return {
      date: {
        value: new Date(), // Selected date object
        displayed: "",     // Displayed/edited date string
        picked: ""         // Date string from the date picker
      },
      time: {
        value: { h: 0, m: 0 }, // Selected time object
        picked: ""             // Time string from the time picker
      },
      menuClasses: {
        menuDate: "",
        menuTime: ""
      },
      selects: {
        day:    null,
        month:  null,
        year:   null,
        hour:   null,
        minute: null
      },
      showDate: !!this.mode.match(/^date/),
      showTime: !!this.mode.match(/time$/),
      pastDatesAllowed: true,
      futureDatesAllowed: true,
      // https://github.com/vuetifyjs/vuetify/issues/4502#issuecomment-403077205
      timeMenuIsOpen: false
    };
  },
  watch: {
    'date.value': function (value) {
      this.date.displayed = this.formatDate(value);
      this.date.picked = this.formatDateAsISO(value);

      this.selects.day.value   = this.date.value.getDate();
      this.selects.month.value = this.date.value.getMonth() + 1;
      this.selects.year.value  = this.date.value.getFullYear();
    },
    'date.picked': function (picked) {
      // If the date input has focus, do not update date.value
      // and date.displayed, because this will change the contents of the input
      // while the user is entering it.
      if (document.activeElement === this.$refs.dateInput)
        return;

      this.date.value = new Date(picked);
      this.date.displayed = this.formatDate(this.date.value);
    },
    'date.displayed': function (displayed) {
      // Wrapped in a try block, because the value might be
      // an invalid/incomplete date
      try {
        this.date.picked = this.formatDateAsISO(new Date(displayed));
      }
      catch {}
    },
    'time.picked': function (picked) {
      this.time.value = {
        h: parseInt(picked.split(':')[0]),
        m: parseInt(picked.split(':')[1])
      };

      if (this.selects.hour)
        this.selects.hour.value = this.time.value.h;
      if (this.selects.minute)
        this.selects.minute.value = this.time.value.m;
    }
  },
  methods: {
    formatDateAsISO: function (date) {
      return date.toISOString().substr(0, 10);
    },
    formatDate: function (date) {
      return this.formatDateAsISO(date);
    },
    formatTime: function (time) {
      return ('00' + time.h).slice(-2) + ':' + ('00' + time.m).slice(-2);
    },
    allowedDates: function (val) {
      var date = new Date(val);
      var now = new Date();
      
      if (!this.pastDatesAllowed && date < now)
        return false;
      
      if (!this.futureDatesAllowed && date > now)
        return false;
      
      return true;
    },
    initializeFromSelects: function () {
      var parentNode = (this.originalField || this.$el.parentNode);

      this.selects.day    = parentNode.querySelector('select[name$="Day"]');
      this.selects.month  = parentNode.querySelector('select[name$="Month"]');
      this.selects.year   = parentNode.querySelector('select[name$="Year"]');
      this.selects.hour   = parentNode.querySelector('select[name$="Hour"]');
      this.selects.minute = parentNode.querySelector('select[name$="Minute"]');

      if (this.selects.day)
        this.date.value.setDate(this.selects.day.value);
      if (this.selects.month)
        this.date.value.setMonth(this.selects.month.value-1);
      if (this.selects.year)
        this.date.value.setFullYear(this.selects.year.value);

      this.date.picked = this.formatDateAsISO(this.date.value);
      this.date.displayed = this.formatDate(this.date.value);

      if (this.selects.hour)
        this.time.value.h = parseInt(this.selects.hour.value);
      if (this.selects.minute)
        this.time.value.m = parseInt(this.selects.minute.value);

      this.time.picked = this.formatTime(this.time.value);

      if (!this.selects.hour && !this.selects.minute)
        this.showTime = false;

      if (this.selects.day) {
        if (this.selects.day.classList.contains('Validate_DateNotInFuture'))
          this.futureDatesAllowed = false;
        if (this.selects.day.classList.contains('Validate_DateInFuture'))
          this.pastDatesAllowed = false;
      }
    },
    updateClasses: function (ref) {
      setTimeout((function () {
        var contentOffsetTop   = this.offset(this.$refs[ref].$refs.content).top;
        var dateInputOffsetTop = this.offset(this.$refs.dateInput).top;

        if (contentOffsetTop != 0 && contentOffsetTop < dateInputOffsetTop)
          this.menuClasses[ref] = 'menu-above';
        else
          this.menuClasses[ref] = 'menu-below';
      }).bind(this), 100);
    },
    offset: function (element) {
	    var rect = element.getBoundingClientRect(),
	      scrollLeft = window.pageXOffset || document.documentElement.scrollLeft,
	      scrollTop = window.pageYOffset || document.documentElement.scrollTop;
	    return { top: rect.top + scrollTop, left: rect.left + scrollLeft };
	  }
  },
  mounted: function () {
    this.$el.parentElement.classList.toggle('cmt-otrs-datetime-hidden', true);
    // Remove pieces of text between date and time selects
    this.$el.parentElement.childNodes.forEach(function (node) {
      if (node.nodeType == Node.TEXT_NODE)
        node.parentNode.removeChild(node);
    });

    this.initializeFromSelects();
  }
}
</script>

<style>
.menu-below {
  contain: initial;
  margin-top: 16px;
  overflow: visible;
  /* z-index: 1000 !important; */
}

.menu-below::before {
  color: #fff;
  content: "\0F0360";
  font-family: 'Material Design Icons';
  font-size: 50px;
  height: 30px;
  left: 0;
  line-height: 48px;
  position: absolute;
  text-shadow: 0px 0px 10px rgb(0 0 0 / 65%);
  top: 0;
  transform: translateY(-100%);
  width: 30px;
  /* z-index: auto; */
}

.menu-above {
  contain: initial;
  margin-top: -16px;
  overflow: visible;
  /* z-index: 1000 !important */
}

.menu-above::before {
  bottom: -9px;
  color: #fff;
  content: "\0F035D";
  font-family: 'Material Design Icons';
  font-size: 50px;
  height: 30px;
  left: 0;
  line-height: 48px;
  position: absolute;
  text-shadow: 0px 0px 10px rgb(0 0 0 / 65%);
  width: 30px;
  /* z-index: auto; */
}

input.dateTimePicker-dateInput {
  width: 8em;
}

input.dateTimePicker-timeInput {
  margin-left: 0.5em;
  width: 6em;
}
</style>

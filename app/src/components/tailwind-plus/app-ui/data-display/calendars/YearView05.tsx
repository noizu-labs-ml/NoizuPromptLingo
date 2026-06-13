// TO REVIEW: Convert to reusable component with props and design system tokens
// @ts-nocheck
'use client'

import { ChevronDownIcon, ChevronLeftIcon, ChevronRightIcon, EllipsisHorizontalIcon } from '@heroicons/react/20/solid'
import { Menu, MenuButton, MenuItem, MenuItems } from '@headlessui/react'

const months = [
  {
    name: 'January',
    days: [
      { date: '2021-12-27' },
      { date: '2021-12-28' },
      { date: '2021-12-29' },
      { date: '2021-12-30' },
      { date: '2021-12-31' },
      { date: '2022-01-01', isCurrentMonth: true },
      { date: '2022-01-02', isCurrentMonth: true },
      { date: '2022-01-03', isCurrentMonth: true },
      { date: '2022-01-04', isCurrentMonth: true },
      { date: '2022-01-05', isCurrentMonth: true },
      { date: '2022-01-06', isCurrentMonth: true },
      { date: '2022-01-07', isCurrentMonth: true },
      { date: '2022-01-08', isCurrentMonth: true },
      { date: '2022-01-09', isCurrentMonth: true },
      { date: '2022-01-10', isCurrentMonth: true },
      { date: '2022-01-11', isCurrentMonth: true },
      { date: '2022-01-12', isCurrentMonth: true, isToday: true },
      { date: '2022-01-13', isCurrentMonth: true },
      { date: '2022-01-14', isCurrentMonth: true },
      { date: '2022-01-15', isCurrentMonth: true },
      { date: '2022-01-16', isCurrentMonth: true },
      { date: '2022-01-17', isCurrentMonth: true },
      { date: '2022-01-18', isCurrentMonth: true },
      { date: '2022-01-19', isCurrentMonth: true },
      { date: '2022-01-20', isCurrentMonth: true },
      { date: '2022-01-21', isCurrentMonth: true },
      { date: '2022-01-22', isCurrentMonth: true },
      { date: '2022-01-23', isCurrentMonth: true },
      { date: '2022-01-24', isCurrentMonth: true },
      { date: '2022-01-25', isCurrentMonth: true },
      { date: '2022-01-26', isCurrentMonth: true },
      { date: '2022-01-27', isCurrentMonth: true },
      { date: '2022-01-28', isCurrentMonth: true },
      { date: '2022-01-29', isCurrentMonth: true },
      { date: '2022-01-30', isCurrentMonth: true },
      { date: '2022-01-31', isCurrentMonth: true },
      { date: '2022-02-01' },
      { date: '2022-02-02' },
      { date: '2022-02-03' },
      { date: '2022-02-04' },
      { date: '2022-02-05' },
      { date: '2022-02-06' },
    ],
  },
  {
    name: 'February',
    days: [
      { date: '2022-01-31' },
      { date: '2022-02-01', isCurrentMonth: true },
      { date: '2022-02-02', isCurrentMonth: true },
      { date: '2022-02-03', isCurrentMonth: true },
      { date: '2022-02-04', isCurrentMonth: true },
      { date: '2022-02-05', isCurrentMonth: true },
      { date: '2022-02-06', isCurrentMonth: true },
      { date: '2022-02-07', isCurrentMonth: true },
      { date: '2022-02-08', isCurrentMonth: true },
      { date: '2022-02-09', isCurrentMonth: true },
      { date: '2022-02-10', isCurrentMonth: true },
      { date: '2022-02-11', isCurrentMonth: true },
      { date: '2022-02-12', isCurrentMonth: true },
      { date: '2022-02-13', isCurrentMonth: true },
      { date: '2022-02-14', isCurrentMonth: true },
      { date: '2022-02-15', isCurrentMonth: true },
      { date: '2022-02-16', isCurrentMonth: true },
      { date: '2022-02-17', isCurrentMonth: true },
      { date: '2022-02-18', isCurrentMonth: true },
      { date: '2022-02-19', isCurrentMonth: true },
      { date: '2022-02-20', isCurrentMonth: true },
      { date: '2022-02-21', isCurrentMonth: true },
      { date: '2022-02-22', isCurrentMonth: true },
      { date: '2022-02-23', isCurrentMonth: true },
      { date: '2022-02-24', isCurrentMonth: true },
      { date: '2022-02-25', isCurrentMonth: true },
      { date: '2022-02-26', isCurrentMonth: true },
      { date: '2022-02-27', isCurrentMonth: true },
      { date: '2022-02-28', isCurrentMonth: true },
      { date: '2022-03-01' },
      { date: '2022-03-02' },
      { date: '2022-03-03' },
      { date: '2022-03-04' },
      { date: '2022-03-05' },
      { date: '2022-03-06' },
      { date: '2022-03-07' },
      { date: '2022-03-08' },
      { date: '2022-03-09' },
      { date: '2022-03-10' },
      { date: '2022-03-11' },
      { date: '2022-03-12' },
      { date: '2022-03-13' },
    ],
  },
  {
    name: 'March',
    days: [
      { date: '2022-02-28' },
      { date: '2022-03-01', isCurrentMonth: true },
      { date: '2022-03-02', isCurrentMonth: true },
      { date: '2022-03-03', isCurrentMonth: true },
      { date: '2022-03-04', isCurrentMonth: true },
      { date: '2022-03-05', isCurrentMonth: true },
      { date: '2022-03-06', isCurrentMonth: true },
      { date: '2022-03-07', isCurrentMonth: true },
      { date: '2022-03-08', isCurrentMonth: true },
      { date: '2022-03-09', isCurrentMonth: true },
      { date: '2022-03-10', isCurrentMonth: true },
      { date: '2022-03-11', isCurrentMonth: true },
      { date: '2022-03-12', isCurrentMonth: true },
      { date: '2022-03-13', isCurrentMonth: true },
      { date: '2022-03-14', isCurrentMonth: true },
      { date: '2022-03-15', isCurrentMonth: true },
      { date: '2022-03-16', isCurrentMonth: true },
      { date: '2022-03-17', isCurrentMonth: true },
      { date: '2022-03-18', isCurrentMonth: true },
      { date: '2022-03-19', isCurrentMonth: true },
      { date: '2022-03-20', isCurrentMonth: true },
      { date: '2022-03-21', isCurrentMonth: true },
      { date: '2022-03-22', isCurrentMonth: true },
      { date: '2022-03-23', isCurrentMonth: true },
      { date: '2022-03-24', isCurrentMonth: true },
      { date: '2022-03-25', isCurrentMonth: true },
      { date: '2022-03-26', isCurrentMonth: true },
      { date: '2022-03-27', isCurrentMonth: true },
      { date: '2022-03-28', isCurrentMonth: true },
      { date: '2022-03-29', isCurrentMonth: true },
      { date: '2022-03-30', isCurrentMonth: true },
      { date: '2022-03-31', isCurrentMonth: true },
      { date: '2022-04-01' },
      { date: '2022-04-02' },
      { date: '2022-04-03' },
      { date: '2022-04-04' },
      { date: '2022-04-05' },
      { date: '2022-04-06' },
      { date: '2022-04-07' },
      { date: '2022-04-08' },
      { date: '2022-04-09' },
      { date: '2022-04-10' },
    ],
  },
  {
    name: 'April',
    days: [
      { date: '2022-03-28' },
      { date: '2022-03-29' },
      { date: '2022-03-30' },
      { date: '2022-03-31' },
      { date: '2022-04-01', isCurrentMonth: true },
      { date: '2022-04-02', isCurrentMonth: true },
      { date: '2022-04-03', isCurrentMonth: true },
      { date: '2022-04-04', isCurrentMonth: true },
      { date: '2022-04-05', isCurrentMonth: true },
      { date: '2022-04-06', isCurrentMonth: true },
      { date: '2022-04-07', isCurrentMonth: true },
      { date: '2022-04-08', isCurrentMonth: true },
      { date: '2022-04-09', isCurrentMonth: true },
      { date: '2022-04-10', isCurrentMonth: true },
      { date: '2022-04-11', isCurrentMonth: true },
      { date: '2022-04-12', isCurrentMonth: true },
      { date: '2022-04-13', isCurrentMonth: true },
      { date: '2022-04-14', isCurrentMonth: true },
      { date: '2022-04-15', isCurrentMonth: true },
      { date: '2022-04-16', isCurrentMonth: true },
      { date: '2022-04-17', isCurrentMonth: true },
      { date: '2022-04-18', isCurrentMonth: true },
      { date: '2022-04-19', isCurrentMonth: true },
      { date: '2022-04-20', isCurrentMonth: true },
      { date: '2022-04-21', isCurrentMonth: true },
      { date: '2022-04-22', isCurrentMonth: true },
      { date: '2022-04-23', isCurrentMonth: true },
      { date: '2022-04-24', isCurrentMonth: true },
      { date: '2022-04-25', isCurrentMonth: true },
      { date: '2022-04-26', isCurrentMonth: true },
      { date: '2022-04-27', isCurrentMonth: true },
      { date: '2022-04-28', isCurrentMonth: true },
      { date: '2022-04-29', isCurrentMonth: true },
      { date: '2022-04-30', isCurrentMonth: true },
      { date: '2022-05-01' },
      { date: '2022-05-02' },
      { date: '2022-05-03' },
      { date: '2022-05-04' },
      { date: '2022-05-05' },
      { date: '2022-05-06' },
      { date: '2022-05-07' },
      { date: '2022-05-08' },
    ],
  },
  {
    name: 'May',
    days: [
      { date: '2022-04-25' },
      { date: '2022-04-26' },
      { date: '2022-04-27' },
      { date: '2022-04-28' },
      { date: '2022-04-29' },
      { date: '2022-04-30' },
      { date: '2022-05-01', isCurrentMonth: true },
      { date: '2022-05-02', isCurrentMonth: true },
      { date: '2022-05-03', isCurrentMonth: true },
      { date: '2022-05-04', isCurrentMonth: true },
      { date: '2022-05-05', isCurrentMonth: true },
      { date: '2022-05-06', isCurrentMonth: true },
      { date: '2022-05-07', isCurrentMonth: true },
      { date: '2022-05-08', isCurrentMonth: true },
      { date: '2022-05-09', isCurrentMonth: true },
      { date: '2022-05-10', isCurrentMonth: true },
      { date: '2022-05-11', isCurrentMonth: true },
      { date: '2022-05-12', isCurrentMonth: true },
      { date: '2022-05-13', isCurrentMonth: true },
      { date: '2022-05-14', isCurrentMonth: true },
      { date: '2022-05-15', isCurrentMonth: true },
      { date: '2022-05-16', isCurrentMonth: true },
      { date: '2022-05-17', isCurrentMonth: true },
      { date: '2022-05-18', isCurrentMonth: true },
      { date: '2022-05-19', isCurrentMonth: true },
      { date: '2022-05-20', isCurrentMonth: true },
      { date: '2022-05-21', isCurrentMonth: true },
      { date: '2022-05-22', isCurrentMonth: true },
      { date: '2022-05-23', isCurrentMonth: true },
      { date: '2022-05-24', isCurrentMonth: true },
      { date: '2022-05-25', isCurrentMonth: true },
      { date: '2022-05-26', isCurrentMonth: true },
      { date: '2022-05-27', isCurrentMonth: true },
      { date: '2022-05-28', isCurrentMonth: true },
      { date: '2022-05-29', isCurrentMonth: true },
      { date: '2022-05-30', isCurrentMonth: true },
      { date: '2022-05-31', isCurrentMonth: true },
      { date: '2022-06-01' },
      { date: '2022-06-02' },
      { date: '2022-06-03' },
      { date: '2022-06-04' },
      { date: '2022-06-05' },
    ],
  },
  {
    name: 'June',
    days: [
      { date: '2022-05-30' },
      { date: '2022-05-31' },
      { date: '2022-06-01', isCurrentMonth: true },
      { date: '2022-06-02', isCurrentMonth: true },
      { date: '2022-06-03', isCurrentMonth: true },
      { date: '2022-06-04', isCurrentMonth: true },
      { date: '2022-06-05', isCurrentMonth: true },
      { date: '2022-06-06', isCurrentMonth: true },
      { date: '2022-06-07', isCurrentMonth: true },
      { date: '2022-06-08', isCurrentMonth: true },
      { date: '2022-06-09', isCurrentMonth: true },
      { date: '2022-06-10', isCurrentMonth: true },
      { date: '2022-06-11', isCurrentMonth: true },
      { date: '2022-06-12', isCurrentMonth: true },
      { date: '2022-06-13', isCurrentMonth: true },
      { date: '2022-06-14', isCurrentMonth: true },
      { date: '2022-06-15', isCurrentMonth: true },
      { date: '2022-06-16', isCurrentMonth: true },
      { date: '2022-06-17', isCurrentMonth: true },
      { date: '2022-06-18', isCurrentMonth: true },
      { date: '2022-06-19', isCurrentMonth: true },
      { date: '2022-06-20', isCurrentMonth: true },
      { date: '2022-06-21', isCurrentMonth: true },
      { date: '2022-06-22', isCurrentMonth: true },
      { date: '2022-06-23', isCurrentMonth: true },
      { date: '2022-06-24', isCurrentMonth: true },
      { date: '2022-06-25', isCurrentMonth: true },
      { date: '2022-06-26', isCurrentMonth: true },
      { date: '2022-06-27', isCurrentMonth: true },
      { date: '2022-06-28', isCurrentMonth: true },
      { date: '2022-06-29', isCurrentMonth: true },
      { date: '2022-06-30', isCurrentMonth: true },
      { date: '2022-07-01' },
      { date: '2022-07-02' },
      { date: '2022-07-03' },
      { date: '2022-07-04' },
      { date: '2022-07-05' },
      { date: '2022-07-06' },
      { date: '2022-07-07' },
      { date: '2022-07-08' },
      { date: '2022-07-09' },
      { date: '2022-07-10' },
    ],
  },
  {
    name: 'July',
    days: [
      { date: '2022-06-27' },
      { date: '2022-06-28' },
      { date: '2022-06-29' },
      { date: '2022-06-30' },
      { date: '2022-07-01', isCurrentMonth: true },
      { date: '2022-07-02', isCurrentMonth: true },
      { date: '2022-07-03', isCurrentMonth: true },
      { date: '2022-07-04', isCurrentMonth: true },
      { date: '2022-07-05', isCurrentMonth: true },
      { date: '2022-07-06', isCurrentMonth: true },
      { date: '2022-07-07', isCurrentMonth: true },
      { date: '2022-07-08', isCurrentMonth: true },
      { date: '2022-07-09', isCurrentMonth: true },
      { date: '2022-07-10', isCurrentMonth: true },
      { date: '2022-07-11', isCurrentMonth: true },
      { date: '2022-07-12', isCurrentMonth: true },
      { date: '2022-07-13', isCurrentMonth: true },
      { date: '2022-07-14', isCurrentMonth: true },
      { date: '2022-07-15', isCurrentMonth: true },
      { date: '2022-07-16', isCurrentMonth: true },
      { date: '2022-07-17', isCurrentMonth: true },
      { date: '2022-07-18', isCurrentMonth: true },
      { date: '2022-07-19', isCurrentMonth: true },
      { date: '2022-07-20', isCurrentMonth: true },
      { date: '2022-07-21', isCurrentMonth: true },
      { date: '2022-07-22', isCurrentMonth: true },
      { date: '2022-07-23', isCurrentMonth: true },
      { date: '2022-07-24', isCurrentMonth: true },
      { date: '2022-07-25', isCurrentMonth: true },
      { date: '2022-07-26', isCurrentMonth: true },
      { date: '2022-07-27', isCurrentMonth: true },
      { date: '2022-07-28', isCurrentMonth: true },
      { date: '2022-07-29', isCurrentMonth: true },
      { date: '2022-07-30', isCurrentMonth: true },
      { date: '2022-07-31', isCurrentMonth: true },
      { date: '2022-08-01' },
      { date: '2022-08-02' },
      { date: '2022-08-03' },
      { date: '2022-08-04' },
      { date: '2022-08-05' },
      { date: '2022-08-06' },
      { date: '2022-08-07' },
    ],
  },
  {
    name: 'August',
    days: [
      { date: '2022-08-01', isCurrentMonth: true },
      { date: '2022-08-02', isCurrentMonth: true },
      { date: '2022-08-03', isCurrentMonth: true },
      { date: '2022-08-04', isCurrentMonth: true },
      { date: '2022-08-05', isCurrentMonth: true },
      { date: '2022-08-06', isCurrentMonth: true },
      { date: '2022-08-07', isCurrentMonth: true },
      { date: '2022-08-08', isCurrentMonth: true },
      { date: '2022-08-09', isCurrentMonth: true },
      { date: '2022-08-10', isCurrentMonth: true },
      { date: '2022-08-11', isCurrentMonth: true },
      { date: '2022-08-12', isCurrentMonth: true },
      { date: '2022-08-13', isCurrentMonth: true },
      { date: '2022-08-14', isCurrentMonth: true },
      { date: '2022-08-15', isCurrentMonth: true },
      { date: '2022-08-16', isCurrentMonth: true },
      { date: '2022-08-17', isCurrentMonth: true },
      { date: '2022-08-18', isCurrentMonth: true },
      { date: '2022-08-19', isCurrentMonth: true },
      { date: '2022-08-20', isCurrentMonth: true },
      { date: '2022-08-21', isCurrentMonth: true },
      { date: '2022-08-22', isCurrentMonth: true },
      { date: '2022-08-23', isCurrentMonth: true },
      { date: '2022-08-24', isCurrentMonth: true },
      { date: '2022-08-25', isCurrentMonth: true },
      { date: '2022-08-26', isCurrentMonth: true },
      { date: '2022-08-27', isCurrentMonth: true },
      { date: '2022-08-28', isCurrentMonth: true },
      { date: '2022-08-29', isCurrentMonth: true },
      { date: '2022-08-30', isCurrentMonth: true },
      { date: '2022-08-31', isCurrentMonth: true },
      { date: '2022-09-01' },
      { date: '2022-09-02' },
      { date: '2022-09-03' },
      { date: '2022-09-04' },
      { date: '2022-09-05' },
      { date: '2022-09-06' },
      { date: '2022-09-07' },
      { date: '2022-09-08' },
      { date: '2022-09-09' },
      { date: '2022-09-10' },
      { date: '2022-09-11' },
    ],
  },
  {
    name: 'September',
    days: [
      { date: '2022-08-29' },
      { date: '2022-08-30' },
      { date: '2022-08-31' },
      { date: '2022-09-01', isCurrentMonth: true },
      { date: '2022-09-02', isCurrentMonth: true },
      { date: '2022-09-03', isCurrentMonth: true },
      { date: '2022-09-04', isCurrentMonth: true },
      { date: '2022-09-05', isCurrentMonth: true },
      { date: '2022-09-06', isCurrentMonth: true },
      { date: '2022-09-07', isCurrentMonth: true },
      { date: '2022-09-08', isCurrentMonth: true },
      { date: '2022-09-09', isCurrentMonth: true },
      { date: '2022-09-10', isCurrentMonth: true },
      { date: '2022-09-11', isCurrentMonth: true },
      { date: '2022-09-12', isCurrentMonth: true },
      { date: '2022-09-13', isCurrentMonth: true },
      { date: '2022-09-14', isCurrentMonth: true },
      { date: '2022-09-15', isCurrentMonth: true },
      { date: '2022-09-16', isCurrentMonth: true },
      { date: '2022-09-17', isCurrentMonth: true },
      { date: '2022-09-18', isCurrentMonth: true },
      { date: '2022-09-19', isCurrentMonth: true },
      { date: '2022-09-20', isCurrentMonth: true },
      { date: '2022-09-21', isCurrentMonth: true },
      { date: '2022-09-22', isCurrentMonth: true },
      { date: '2022-09-23', isCurrentMonth: true },
      { date: '2022-09-24', isCurrentMonth: true },
      { date: '2022-09-25', isCurrentMonth: true },
      { date: '2022-09-26', isCurrentMonth: true },
      { date: '2022-09-27', isCurrentMonth: true },
      { date: '2022-09-28', isCurrentMonth: true },
      { date: '2022-09-29', isCurrentMonth: true },
      { date: '2022-09-30', isCurrentMonth: true },
      { date: '2022-10-01' },
      { date: '2022-10-02' },
      { date: '2022-10-03' },
      { date: '2022-10-04' },
      { date: '2022-10-05' },
      { date: '2022-10-06' },
      { date: '2022-10-07' },
      { date: '2022-10-08' },
      { date: '2022-10-09' },
    ],
  },
  {
    name: 'October',
    days: [
      { date: '2022-09-26' },
      { date: '2022-09-27' },
      { date: '2022-09-28' },
      { date: '2022-09-29' },
      { date: '2022-09-30' },
      { date: '2022-10-01', isCurrentMonth: true },
      { date: '2022-10-02', isCurrentMonth: true },
      { date: '2022-10-03', isCurrentMonth: true },
      { date: '2022-10-04', isCurrentMonth: true },
      { date: '2022-10-05', isCurrentMonth: true },
      { date: '2022-10-06', isCurrentMonth: true },
      { date: '2022-10-07', isCurrentMonth: true },
      { date: '2022-10-08', isCurrentMonth: true },
      { date: '2022-10-09', isCurrentMonth: true },
      { date: '2022-10-10', isCurrentMonth: true },
      { date: '2022-10-11', isCurrentMonth: true },
      { date: '2022-10-12', isCurrentMonth: true },
      { date: '2022-10-13', isCurrentMonth: true },
      { date: '2022-10-14', isCurrentMonth: true },
      { date: '2022-10-15', isCurrentMonth: true },
      { date: '2022-10-16', isCurrentMonth: true },
      { date: '2022-10-17', isCurrentMonth: true },
      { date: '2022-10-18', isCurrentMonth: true },
      { date: '2022-10-19', isCurrentMonth: true },
      { date: '2022-10-20', isCurrentMonth: true },
      { date: '2022-10-21', isCurrentMonth: true },
      { date: '2022-10-22', isCurrentMonth: true },
      { date: '2022-10-23', isCurrentMonth: true },
      { date: '2022-10-24', isCurrentMonth: true },
      { date: '2022-10-25', isCurrentMonth: true },
      { date: '2022-10-26', isCurrentMonth: true },
      { date: '2022-10-27', isCurrentMonth: true },
      { date: '2022-10-28', isCurrentMonth: true },
      { date: '2022-10-29', isCurrentMonth: true },
      { date: '2022-10-30', isCurrentMonth: true },
      { date: '2022-10-31', isCurrentMonth: true },
      { date: '2022-11-01' },
      { date: '2022-11-02' },
      { date: '2022-11-03' },
      { date: '2022-11-04' },
      { date: '2022-11-05' },
      { date: '2022-11-06' },
    ],
  },
  {
    name: 'November',
    days: [
      { date: '2022-10-31' },
      { date: '2022-11-01', isCurrentMonth: true },
      { date: '2022-11-02', isCurrentMonth: true },
      { date: '2022-11-03', isCurrentMonth: true },
      { date: '2022-11-04', isCurrentMonth: true },
      { date: '2022-11-05', isCurrentMonth: true },
      { date: '2022-11-06', isCurrentMonth: true },
      { date: '2022-11-07', isCurrentMonth: true },
      { date: '2022-11-08', isCurrentMonth: true },
      { date: '2022-11-09', isCurrentMonth: true },
      { date: '2022-11-10', isCurrentMonth: true },
      { date: '2022-11-11', isCurrentMonth: true },
      { date: '2022-11-12', isCurrentMonth: true },
      { date: '2022-11-13', isCurrentMonth: true },
      { date: '2022-11-14', isCurrentMonth: true },
      { date: '2022-11-15', isCurrentMonth: true },
      { date: '2022-11-16', isCurrentMonth: true },
      { date: '2022-11-17', isCurrentMonth: true },
      { date: '2022-11-18', isCurrentMonth: true },
      { date: '2022-11-19', isCurrentMonth: true },
      { date: '2022-11-20', isCurrentMonth: true },
      { date: '2022-11-21', isCurrentMonth: true },
      { date: '2022-11-22', isCurrentMonth: true },
      { date: '2022-11-23', isCurrentMonth: true },
      { date: '2022-11-24', isCurrentMonth: true },
      { date: '2022-11-25', isCurrentMonth: true },
      { date: '2022-11-26', isCurrentMonth: true },
      { date: '2022-11-27', isCurrentMonth: true },
      { date: '2022-11-28', isCurrentMonth: true },
      { date: '2022-11-29', isCurrentMonth: true },
      { date: '2022-11-30', isCurrentMonth: true },
      { date: '2022-12-01' },
      { date: '2022-12-02' },
      { date: '2022-12-03' },
      { date: '2022-12-04' },
      { date: '2022-12-05' },
      { date: '2022-12-06' },
      { date: '2022-12-07' },
      { date: '2022-12-08' },
      { date: '2022-12-09' },
      { date: '2022-12-10' },
      { date: '2022-12-11' },
    ],
  },
  {
    name: 'December',
    days: [
      { date: '2022-11-28' },
      { date: '2022-11-29' },
      { date: '2022-11-30' },
      { date: '2022-12-01', isCurrentMonth: true },
      { date: '2022-12-02', isCurrentMonth: true },
      { date: '2022-12-03', isCurrentMonth: true },
      { date: '2022-12-04', isCurrentMonth: true },
      { date: '2022-12-05', isCurrentMonth: true },
      { date: '2022-12-06', isCurrentMonth: true },
      { date: '2022-12-07', isCurrentMonth: true },
      { date: '2022-12-08', isCurrentMonth: true },
      { date: '2022-12-09', isCurrentMonth: true },
      { date: '2022-12-10', isCurrentMonth: true },
      { date: '2022-12-11', isCurrentMonth: true },
      { date: '2022-12-12', isCurrentMonth: true },
      { date: '2022-12-13', isCurrentMonth: true },
      { date: '2022-12-14', isCurrentMonth: true },
      { date: '2022-12-15', isCurrentMonth: true },
      { date: '2022-12-16', isCurrentMonth: true },
      { date: '2022-12-17', isCurrentMonth: true },
      { date: '2022-12-18', isCurrentMonth: true },
      { date: '2022-12-19', isCurrentMonth: true },
      { date: '2022-12-20', isCurrentMonth: true },
      { date: '2022-12-21', isCurrentMonth: true },
      { date: '2022-12-22', isCurrentMonth: true },
      { date: '2022-12-23', isCurrentMonth: true },
      { date: '2022-12-24', isCurrentMonth: true },
      { date: '2022-12-25', isCurrentMonth: true },
      { date: '2022-12-26', isCurrentMonth: true },
      { date: '2022-12-27', isCurrentMonth: true },
      { date: '2022-12-28', isCurrentMonth: true },
      { date: '2022-12-29', isCurrentMonth: true },
      { date: '2022-12-30', isCurrentMonth: true },
      { date: '2022-12-31', isCurrentMonth: true },
      { date: '2023-01-01' },
      { date: '2023-01-02' },
      { date: '2023-01-03' },
      { date: '2023-01-04' },
      { date: '2023-01-05' },
      { date: '2023-01-06' },
      { date: '2023-01-07' },
      { date: '2023-01-08' },
    ],
  },
]

export function YearView05() {
  return (
    <div>
      <header className="flex items-center justify-between border-b border-gray-200 px-6 py-4 dark:border-white/10 dark:bg-gray-800/50">
        <h1 className="text-base font-semibold text-gray-900 dark:text-white">
          <time dateTime={2022}>2022</time>
        </h1>
        <div className="flex items-center">
          <div className="relative flex items-center rounded-md bg-white shadow-xs outline -outline-offset-1 outline-gray-300 md:items-stretch dark:bg-white/10 dark:shadow-none dark:outline-white/5">
            <button
              type="button"
              className="flex h-9 w-12 items-center justify-center rounded-l-md pr-1 text-gray-400 hover:text-gray-500 focus:relative md:w-9 md:pr-0 md:hover:bg-gray-50 dark:hover:text-white dark:md:hover:bg-white/10"
            >
              <span className="sr-only">Previous year</span>
              <ChevronLeftIcon aria-hidden="true" className="size-5" />
            </button>
            <button
              type="button"
              className="hidden px-3.5 text-sm font-semibold text-gray-900 hover:bg-gray-50 focus:relative md:block dark:text-white dark:hover:bg-white/10"
            >
              Today
            </button>
            <span className="relative -mx-px h-5 w-px bg-gray-300 md:hidden dark:bg-white/10" />
            <button
              type="button"
              className="flex h-9 w-12 items-center justify-center rounded-r-md pl-1 text-gray-400 hover:text-gray-500 focus:relative md:w-9 md:pl-0 md:hover:bg-gray-50 dark:hover:text-white dark:md:hover:bg-white/10"
            >
              <span className="sr-only">Next year</span>
              <ChevronRightIcon aria-hidden="true" className="size-5" />
            </button>
          </div>
          <div className="hidden md:ml-4 md:flex md:items-center">
            <Menu as="div" className="relative">
              <MenuButton
                type="button"
                className="flex items-center gap-x-1.5 rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-xs inset-ring inset-ring-gray-300 hover:bg-gray-50 dark:bg-white/10 dark:text-white dark:shadow-none dark:inset-ring-white/5 dark:hover:bg-white/20"
              >
                Year view
                <ChevronDownIcon aria-hidden="true" className="-mr-1 size-5 text-gray-400" />
              </MenuButton>

              <MenuItems
                transition
                className="absolute right-0 z-10 mt-3 w-36 origin-top-right overflow-hidden rounded-md bg-white shadow-lg outline-1 outline-black/5 transition data-closed:scale-95 data-closed:transform data-closed:opacity-0 data-enter:duration-100 data-enter:ease-out data-leave:duration-75 data-leave:ease-in dark:bg-gray-800 dark:shadow-none dark:-outline-offset-1 dark:outline-white/5"
              >
                <div className="py-1">
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Day view
                    </a>
                  </MenuItem>
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Week view
                    </a>
                  </MenuItem>
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Month view
                    </a>
                  </MenuItem>
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Year view
                    </a>
                  </MenuItem>
                </div>
              </MenuItems>
            </Menu>
            <div className="ml-6 h-6 w-px bg-gray-300 dark:bg-white/10" />
            <button
              type="button"
              className="ml-6 rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-indigo-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:shadow-none dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-500"
            >
              Add event
            </button>
          </div>
          <div className="ml-6 md:hidden">
            <Menu as="div" className="relative">
              <MenuButton className="relative flex items-center rounded-full text-gray-400 outline-offset-8 hover:text-gray-500 dark:text-gray-400 dark:hover:text-white">
                <span className="absolute -inset-2" />
                <span className="sr-only">Open menu</span>
                <EllipsisHorizontalIcon aria-hidden="true" className="size-5" />
              </MenuButton>

              <MenuItems
                transition
                className="absolute right-0 z-10 mt-3 w-36 origin-top-right divide-y divide-gray-100 overflow-hidden rounded-md bg-white shadow-lg outline-1 outline-black/5 transition data-closed:scale-95 data-closed:transform data-closed:opacity-0 data-enter:duration-100 data-enter:ease-out data-leave:duration-75 data-leave:ease-in dark:divide-white/10 dark:bg-gray-800 dark:-outline-offset-1 dark:outline-white/5"
              >
                <div className="py-1">
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Create event
                    </a>
                  </MenuItem>
                </div>
                <div className="py-1">
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Go to today
                    </a>
                  </MenuItem>
                </div>
                <div className="py-1">
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Day view
                    </a>
                  </MenuItem>
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Week view
                    </a>
                  </MenuItem>
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Month view
                    </a>
                  </MenuItem>
                  <MenuItem>
                    <a
                      href="#"
                      className="block px-4 py-2 text-sm text-gray-700 data-focus:bg-gray-100 data-focus:text-gray-900 data-focus:outline-hidden dark:text-gray-300 dark:data-focus:bg-white/5 dark:data-focus:text-white"
                    >
                      Year view
                    </a>
                  </MenuItem>
                </div>
              </MenuItems>
            </Menu>
          </div>
        </div>
      </header>
      <div className="bg-white dark:bg-gray-900">
        <div className="mx-auto grid max-w-3xl grid-cols-1 gap-x-8 gap-y-16 px-4 py-16 sm:grid-cols-2 sm:px-6 xl:max-w-none xl:grid-cols-3 xl:px-8 2xl:grid-cols-4">
          {months.map((month) => (
            <section key={month.name} className="text-center">
              <h2 className="text-sm font-semibold text-gray-900 dark:text-white">{month.name}</h2>
              <div className="mt-6 grid grid-cols-7 text-xs/6 text-gray-500 dark:text-gray-400">
                <div>M</div>
                <div>T</div>
                <div>W</div>
                <div>T</div>
                <div>F</div>
                <div>S</div>
                <div>S</div>
              </div>
              <div className="isolate mt-2 grid grid-cols-7 gap-px rounded-lg bg-gray-200 text-sm shadow-sm ring-1 ring-gray-200 dark:bg-white/10 dark:shadow-none dark:ring-white/10">
                {month.days.map((day) => (
                  <button
                    key={day.date}
                    type="button"
                    data-is-today={day.isToday ? '' : undefined}
                    data-is-current-month={day.isCurrentMonth ? '' : undefined}
                    className="relative bg-gray-50 py-1.5 text-gray-400 first:rounded-tl-lg last:rounded-br-lg hover:bg-gray-100 focus:z-10 data-is-current-month:bg-white data-is-current-month:text-gray-900 data-is-current-month:hover:bg-gray-100 nth-36:rounded-bl-lg nth-7:rounded-tr-lg dark:bg-gray-900/75 dark:text-gray-500 dark:hover:bg-gray-900/25 dark:data-is-current-month:bg-gray-900 dark:data-is-current-month:text-gray-100 dark:data-is-current-month:hover:bg-gray-900/50"
                  >
                    <time
                      dateTime={day.date}
                      className="mx-auto flex size-7 items-center justify-center rounded-full in-data-is-today:bg-indigo-600 in-data-is-today:font-semibold in-data-is-today:text-white dark:in-data-is-today:bg-indigo-500"
                    >
                      {day.date.split('-').pop().replace(/^0/, '')}
                    </time>
                  </button>
                ))}
              </div>
            </section>
          ))}
        </div>
      </div>
    </div>
  )
}
